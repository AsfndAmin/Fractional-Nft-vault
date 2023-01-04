//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";  
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./Shares.sol";
import "./IFractionalNftVault.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract FractionalNftVault is   
    Initializable,
    AccessControlUpgradeable,
    ERC721HolderUpgradeable,
    ERC721Upgradeable,
    IFractionalNftVault,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable 
{
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    //using safeerc20's for token transfer safety
    using SafeERC20Upgradeable for IERC20Upgradeable;

        // struct to store data for the fractionalized nft
    struct Item {
        address nftOwner;
        address shareToken;
        uint256 nftId;
        uint256 unitPrice;
        uint256 preSaleStartTime;
        uint256 preSaleEndTime;
        uint8 paymentIndx;
    }

    uint256 public fractionId;
    uint256 public serviceFee;
    address public liquidityWallet;
    uint256 private holdoutPeriod;
    uint16 public liquidityShare;  // 100 ---> 1%
    uint16 public ventureShare;  // we need to look for altervative word for company
    uint16 private creatorShare;
    uint16 private creatorFee;
    address private companyShareReceiver;

    // Mapping from itemId -> Item struct
    mapping(uint256 => Item) private vaults;
    // Mapping from paymentIndex -> address of payment token
    mapping(uint16 => address) private paymentToken;
    // Mapping from address of whitelisted -> bool
    mapping(address => bool) private isWhitelisted;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

   // Initializes initial contract state
    // Since we are using UUPS proxy, we cannot use contructor instead need to use this
    function initialize(uint256 _serviceFee, address _liquidityWallet, address _companyShare, uint256 _holdoutPeriod, string memory name_, string memory symbol_) external initializer {
        __AccessControl_init();
        __ERC721Holder_init();
        __UUPSUpgradeable_init();
        __ERC721_init(name_ , symbol_);
        __ReentrancyGuard_init();
        serviceFee = _serviceFee;       // 250 ---> 2.5 %
        liquidityWallet = _liquidityWallet;
        holdoutPeriod = _holdoutPeriod;
        companyShareReceiver = _companyShare;

        //granting roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
  

    }

    //Allows only owner to change the serviceFee (share contract platform serviceFee)
    function setServiceFee(uint256 _serviceFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        serviceFee = _serviceFee;

        emit ServiceFeeUpdated(_serviceFee);  
    }
  
    // Allows user to fractionalize nft
    // only whitelisted users can fractionalize
    // mints a nft to the contract address and uses current vault count as id
    // msg.sender is saved in the item struct as the nft owner address
    function fractionalizeNft(
        string memory _name,
        string memory _symbol,
        address _router,
        uint256 _supply, // in wei
        uint256 _unitPrice, // in wei
        uint256 _preSaleStartTime,
        uint8 _paymentIndx
    ) external override nonReentrant{
        require(isWhitelisted[msg.sender], "Not wl");

        fractionId++;
        _safeMint(
            address(this),
            fractionId
        );
        uint256 amountLiquidityWallet = ((_supply * liquidityShare) / 10000);
        uint256 availableForSale = ((_supply * (10000 - liquidityShare)) / 10000);

        Shares __token = new Shares(
            _name,
            _symbol,
            _supply,
            creatorFee,
            serviceFee,
            msg.sender,
            amountLiquidityWallet,
            availableForSale,
            liquidityWallet,
           _preSaleStartTime + holdoutPeriod
            );
  
         IUniswapV2Router02 router = IUniswapV2Router02(_router);
        // Create a uniswap pair for this new token
       address uniSwapPair = IUniswapV2Factory(router.factory()).createPair(
            address(__token),
            router.WETH()
        );

        vaults[fractionId] = Item({
            nftOwner: address(msg.sender),
            shareToken: address(__token),
            nftId: fractionId,
            unitPrice: _unitPrice,
            preSaleStartTime: _preSaleStartTime,
            preSaleEndTime: _preSaleStartTime + holdoutPeriod,
            paymentIndx: _paymentIndx
        });

        emit FractionalizeNft(
            msg.sender,
            uniSwapPair,
            address(__token),
            _supply,
            _unitPrice,
            fractionId,
            _preSaleStartTime,
            _preSaleStartTime + holdoutPeriod
        );
    }

    // Allows user to buy the _totalShares at _id 
    function buyShare(
        uint256 _id,
        uint256 _totalShares
    ) public override {
        Item memory item = vaults[_id];
        require(
            block.timestamp >= item.preSaleStartTime && item.preSaleEndTime > block.timestamp,
            "FractionalNftVault: Invalid time"
        );

        uint256 finalfee = ((_totalShares * item.unitPrice) / 1 ether);
        require(finalfee >= 10000, "Insufficient payment amount");

        (uint256 companyAmount, uint256 creatorAmount, uint256 liquidityAmount) = calculateShare(finalfee);
        _transferAmount(item.paymentIndx, msg.sender, companyShareReceiver, companyAmount);
        _transferAmount(item.paymentIndx, msg.sender, item.nftOwner, creatorAmount);
        _transferAmount(item.paymentIndx, msg.sender, liquidityWallet, liquidityAmount);

        IERC20Upgradeable(item.shareToken).safeTransfer(msg.sender, _totalShares); 
  
        emit ShareSold(
            msg.sender,
            item.shareToken,
            _totalShares,
            item.unitPrice,
            item.nftId,
            block.timestamp
        );
    }

    function _transferAmount(uint8 _indx, address _msgSender, address receiver, uint256 amount) internal {
        IERC20Upgradeable(paymentToken[_indx]).safeTransferFrom( _msgSender, receiver, amount);
    }

    //calculates the shares for the given amount    
    function calculateShare(uint256 _amount) public view returns(uint256, uint256, uint256) {
        (uint16 companyRatio, uint16 creatorRatio, uint16 liquidityRatio) = getShareRatio();
         uint256 companyA =((_amount * companyRatio)/ 10000) ;
         uint256 creatorA = ((_amount * creatorRatio )/ 10000);
         uint256 liquidityA = ((_amount * liquidityRatio)/ 10000) ;
 
         return(companyA, creatorA, liquidityA);
    }

     // Allows the owner of the fractionalized nft to claim his unsold share tokens
    function claimRemainingShareToken(uint256 _id) external override {
        Item storage item = vaults[_id];

        require(msg.sender == item.nftOwner, "FractionalNftVault: nft owner only");
        uint256 unSoldAmount = IERC20Upgradeable(item.shareToken).balanceOf(address(this));

        require(unSoldAmount > 0, "FractionalNftVault: sold out");
        require(block.timestamp > item.preSaleEndTime, "FractionalNftVault: preSale not finished");
        IERC20Upgradeable(item.shareToken).safeTransfer(msg.sender, unSoldAmount);


        emit ClaimUnSoldToken(msg.sender, unSoldAmount, block.timestamp);
    }

    // Allow only owner to add a payment token at given index 
    function setPaymentToken(uint8 index, address _paymentToken) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(index != 0,"FractionalNftVault: index should not be 0");
        paymentToken[index] = _paymentToken;
    }

     // Allow only owner to whitelist a address to fractionalize 
    function addWhitelist(address[] memory _whiteListAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint16 indx = 0; indx < _whiteListAddress.length; indx++) {
        isWhitelisted[_whiteListAddress[indx]] = true;
        }

        emit WhitelistAdded(_whiteListAddress);
    }

    // Allow only owner to remove a whitelisted a address to fractionalize 
    function addBlacklist(address[] memory _blackListAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint16 indx = 0; indx < _blackListAddress.length; indx++) { 
        isWhitelisted[_blackListAddress[indx]] = false;
        }

        emit BlacklistAdded(_blackListAddress);
    }

     // Allow only owners to change the company, creator and liquidity share
    function setShareRatio(uint16 _companyShare, uint16 _creatorShare, uint16 _liquidityShare) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_companyShare + _creatorShare + _liquidityShare == 10000, "Sum must be equal to 10000 pt");

        ventureShare = _companyShare;
        creatorShare = _creatorShare;
        liquidityShare = _liquidityShare;
        emit ShareRatioChanged(ventureShare, creatorShare,liquidityShare );
    }

    function updateLiquidityWallet(address _newWallet) external {
        require(_newWallet != address(0), "zero address");

        liquidityWallet = _newWallet;
    }

    // Allows users to get check ratios of shares
    function getShareRatio() public view returns(uint16, uint16, uint16) {
        return (ventureShare, creatorShare, liquidityShare);
    }

    // Allows users to get vaults data of given id
    function getVault(uint256 _id) external view returns(Item memory) {
        return vaults[_id];
    }

    // Allows users to get address of payment token on index
    function getPaymentToken(uint16 _index) external view returns(address) {
        return paymentToken[_index];
    }

    // Allow only owner to change the creator fee
    function setOwnerFee(uint16 _fee) external onlyRole(DEFAULT_ADMIN_ROLE){
            creatorFee = _fee;
            emit CreatorFeeUpdated(_fee);
    }

        // Allow only owner to change the companyShareAddress
    function setCompanyShareAddress(address _companyAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
            companyShareReceiver = _companyAddress;
            emit CompanyAddressChanged(_companyAddress);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

   // Allow only admins to perform a future upgrade to the contract
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}
