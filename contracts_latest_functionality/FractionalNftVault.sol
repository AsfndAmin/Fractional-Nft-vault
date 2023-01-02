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

      /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    //using safeerc20's for token transfer safety
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20 for Shares;

    uint256 public vaultCount;
    uint256 public fee;
    address public liquidityWallet;
    uint256 private holdoutPeriod;
    uint16 public liquidityShare;  // 150 ---> 15%
    uint16 public companyShare;
    uint16 private creatorShare;
    uint16 private _ownerRoyalty;
    address private companyShareReceiver;



    // Mapping from itemId -> Item struct
    mapping(uint256 => Item) private vaults;
    // Mapping from paymentIndex -> address of payment token
    mapping(uint16 => address) private paymentToken;
    // Mapping from address of whitelisted -> bool
    mapping(address => bool) private isWhitelisted;

   // Initializes initial contract state
    // Since we are using UUPS proxy, we cannot use contructor instead need to use this
    function initialize(uint256 _fee, address _liquidityWallet, address _companyShare, uint256 _holdoutPeriod, string memory name_, string memory symbol_) external initializer {
        __AccessControl_init();
        __ERC721Holder_init();
        __UUPSUpgradeable_init();
        __ERC721_init(name_ , symbol_);
        __ReentrancyGuard_init();
        fee = _fee;       // 25 ---> 2.5 %
        liquidityWallet = _liquidityWallet;
        holdoutPeriod = _holdoutPeriod;
        companyShareReceiver = _companyShare;

        //granting roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
  

    } 

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

    //Allows only owner to change the fee (share contract platform fee)
    function setfee(uint256 _fee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        fee = _fee;
    }
  
    // Allows user to fractionalize nft
    // only whitelisted users can fractionalize
    // mints a nft to the contract address and uses current vault count as id
    // msg.sender is saved in the item struct as the nft owner address
    function fractionalizeNft(
        string memory _name,
        string memory _symbol,
        uint256 _supply, // in wei
        uint256 _unitPrice, // in wei
        uint256 _preSaleStartTime,
        address _router,
        uint8 _paymentIndx
    ) external override nonReentrant{
        require(isWhitelisted[msg.sender] , "FractionalNftVault: not whiteListed");
        vaultCount++;
        _safeMint(
            address(this),
            vaultCount
        );

        uint256 amountLiquidityWallet = ((_supply * liquidityShare) / 10000);
        uint256 amountMsgsender = ((_supply * (10000 - liquidityShare)) / 10000);

 
        Shares __token = new Shares( _name,
            _symbol,
            _supply,
            _ownerRoyalty,
            fee,
            msg.sender,
            amountLiquidityWallet,
            amountMsgsender,
            liquidityWallet,
           _preSaleStartTime + holdoutPeriod
            );
  
         IUniswapV2Router02 router = IUniswapV2Router02(_router);
        // Create a uniswap pair for this new token
       address uniSwapPair = IUniswapV2Factory(router.factory()).createPair(
            address(__token),
            router.WETH()
        );

        vaults[vaultCount] = Item({
            nftOwner: address(msg.sender),
            shareToken: address(__token),
            nftId: vaultCount,
            unitPrice: _unitPrice,
            preSaleStartTime: _preSaleStartTime,
            preSaleEndTime: _preSaleStartTime + holdoutPeriod,
            paymentIndx: _paymentIndx
        });


        emit FractionalizeNft(
            msg.sender,
            _supply,
            _unitPrice,
            vaultCount,
            address(__token),
            _preSaleStartTime,
            _preSaleStartTime + holdoutPeriod,
            uniSwapPair
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
            "FractionalNftVault: preSale not Started or ended"
        );


        
        uint256 finalfee = ((_totalShares * item.unitPrice) / 1 ether);
        require(finalfee >= 10, "Insufficient payment amount");

        (uint256 companyAmount, uint256 creatorAmount, uint256 liquidityAmount) = calculateShare(finalfee);
        _transferAmount(item.paymentIndx, msg.sender, companyShareReceiver, companyAmount);
        _transferAmount(item.paymentIndx, msg.sender, item.nftOwner, creatorAmount);
        _transferAmount(item.paymentIndx, msg.sender, liquidityWallet, liquidityAmount);

        Shares(item.shareToken).safeTransfer(msg.sender, _totalShares);

        emit ShareSold(
            msg.sender,
            _totalShares,
            item.unitPrice,
            item.nftId,
            item.shareToken,
            block.timestamp
        );
    }

    function _transferAmount(uint8 _indx, address _msgSender, address receiver, uint256 amount) internal {
   // IERC20Upgradeable(paymentToken[_indx]).safeTransferFrom( _msgSender, receiver, amount);
    (bool success, bytes memory data) = address(paymentToken[_indx]).call(abi.encodeWithSelector(0x23b872dd, _msgSender, receiver, amount));
         require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Fractionalnft::transferAmount: transferFrom failed" 
        );
//https://goerli.etherscan.io/tx/0x444f45b69eca9a2cecbe30103fa30e59e39e859c004f1bef7b8599362c55d321  transaction after this functionality
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
        uint256 unSoldAmount = Shares(item.shareToken).balanceOf(address(this));

        require(unSoldAmount > 0, "FractionalNftVault: sold out");
        require(block.timestamp > item.preSaleEndTime, "FractionalNftVault: preSale not finished");
        Shares(item.shareToken).safeTransfer(msg.sender, unSoldAmount);

        emit ClaimUnSoldToken(msg.sender, unSoldAmount, block.timestamp);
    }

    // Allow only owner to add a payment token at given index 
    function setPaymentToken(uint8 index, address _paymentToken) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(index != 0,"FractionalNftVault: index should not be 0");
        paymentToken[index] = _paymentToken;
    }

     // Allow only owner to whitelist a address to fractionalize 
    function addWhitelist(address _whiteListAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isWhitelisted[_whiteListAddress] = true;
        emit whitelistAdded(_whiteListAddress);
    }

    // Allow only owner to remove a whitelisted a address to fractionalize 
    function addBlacklist(address _blackListAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isWhitelisted[_blackListAddress] = false;
        emit blacklistAdded(_blackListAddress);
    }

     // Allow only owners to change the company, creator and liquidity share
    function setShareRatio(uint16 _companyShare, uint16 _creatorShare, uint16 _liquidityShare) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_companyShare + _creatorShare + _liquidityShare == 10000, "Sum must be equal to 10000 pt");

        companyShare = _companyShare;
        creatorShare = _creatorShare;
        liquidityShare = _liquidityShare;
        emit ShareRatioChanged(companyShare, creatorShare,liquidityShare );
    }

    // Allows users to get check ratios of shares
    function getShareRatio() public view returns(uint16, uint16, uint16) {
        return (companyShare, creatorShare, liquidityShare);
    }

    // Allows users to get vaults data of given id
    function getVault(uint256 _id) external view returns(Item memory) {
        return vaults[_id];
    }

    // Allows users to get address of payment token on index
    function getPaymentToken(uint16 _index) external view returns(address) {
        return paymentToken[_index];
    }

    // Allow only owner to change the royalty
    function setOwnerRoyality(uint16 _royality) external onlyRole(DEFAULT_ADMIN_ROLE){
            _ownerRoyalty = _royality;
            emit royalityChanged(_royality);
    }

        // Allow only owner to change the companyShareAddress
    function setCompanyShareAddress(address _companyAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
            companyShareReceiver = _companyAddress;
            emit companyAddressChanged(_companyAddress);
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
     function checkUpdate()external pure returns(uint256){
        return 1;
    }
    
}
