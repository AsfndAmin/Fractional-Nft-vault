//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "./Shares.sol";
import "./IFractionalNftVault.sol";

contract FractionalNftVault is   
    Initializable,
    OwnableUpgradeable,
    ERC721HolderUpgradeable,
    ERC721Upgradeable,
    IFractionalNftVault,
    UUPSUpgradeable 
{

      /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


    using SafeERC20Upgradeable for IERC20Upgradeable;
     using SafeERC20Upgradeable for Shares;
    uint256 public vaultCount = 1;
    uint256 public fee;
    address public liquidityWallet;
    uint256 private holdoutPeriod;
    uint16 public liquidityShare;  // 150 ---> 15%
    uint16 public companyShare;
    uint16 private creatorShare;
    uint16 private _ownerRoyalty;

    address private sharesAddress;

  

    mapping(uint256 => Item) private vaults;
    mapping(uint16 => address) private paymentToken;
    mapping(address => bool) private isWhitelisted;

    function initialize(uint256 _fee, address _liquidityWallet, uint256 _holdoutPeriod, string memory name_, string memory symbol_) external initializer {
        __Ownable_init();
        __ERC721Holder_init();
        __UUPSUpgradeable_init();
        __ERC721_init(name_ , symbol_);
        fee = _fee;       // 25 ---> 2.5 %
        liquidityWallet = _liquidityWallet;
        holdoutPeriod = _holdoutPeriod;
    } 

    struct Item {
        address nftOwner;
        address shareToken;
        uint256 nftId;
        uint256 unitPrice;
        uint256 preSaleStartTime;
        uint256 preSaleEndTime;
        uint8 paymentIndx;
    }

    function setfee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

  //   bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
     function implementation() public view returns (address) {
        return _getImplementation();
    }

    // function _implementation() internal override view returns (address) {
    //     return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    // }    


    function fractionalizeNft(
        string memory _name,
        string memory _symbol,
        uint256 _supply, // in wei
        uint256 _unitPrice, // in wei
        uint256 _preSaleStartTime,
        uint8 _paymentIndx
    ) external override {
        require(isWhitelisted[msg.sender] , "FractionalNftVault: not whiteListed");

        _safeMint(
            address(this),
            vaultCount
        );

        uint256 amountLiquidityWallet = ((_supply * liquidityShare) / 1000);
        uint256 amountMsgsender = ((_supply * (1000 - liquidityShare)) / 1000);

        // Shares __token = new Shares();
        // __token.initialize(
        //     _name,
        //     _symbol,
        //     _supply,
        //     _ownerRoyalty,
        //     fee,
        //     msg.sender,
        //     amountLiquidityWallet,
        //     amountMsgsender,
        //     liquidityWallet,
        //     block.timestamp + holdoutPeriod
        // );
        Shares __token = new Shares();
        // assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        // StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = address(__token);
        // Address.functionDelegateCall(
        //     address(__token),
        //    (bool success, bytes memory data) = address(__token).call(abi.encodeWithSignature("initialize(string,string,uint256,uint256,uint256,address,uint256,uint256,address,uint256)",
        //     _name,
        //     _symbol,
        //     _supply,
        //     _ownerRoyalty,
        //     fee,
        //     msg.sender,
        //     amountLiquidityWallet,
        //     amountMsgsender,
        //     liquidityWallet,
        //     block.timestamp + holdoutPeriod)
        // );
        (bool success, bytes memory result) = address(__token).call(abi.encodeWithSignature("initialize(string,string,uint256,uint256,uint256,address,uint256,uint256,address,uint256)",
            _name,
            _symbol,
            _supply,
            _ownerRoyalty,
            fee,
            msg.sender,
            amountLiquidityWallet,
            amountMsgsender,
            liquidityWallet,
            block.timestamp + holdoutPeriod)
        );

        vaults[vaultCount] = Item({
            nftOwner: address(msg.sender),
            shareToken: address(__token),
            nftId: vaultCount,
            unitPrice: _unitPrice,
            preSaleStartTime: _preSaleStartTime,
            preSaleEndTime: block.timestamp + holdoutPeriod,
            paymentIndx: _paymentIndx
        });

        emit FractionalizeNft(
            msg.sender,
            _supply,
            _unitPrice,
            vaultCount,
            address(__token),
            _preSaleStartTime,
            block.timestamp + holdoutPeriod
        );
        vaultCount++;
        emit Response(success, result);
    }

    function buyShare(
        uint256 _id,
        uint256 _totalAmount
    ) public override {
        Item memory item = vaults[_id];
        require(
            block.timestamp >= item.preSaleStartTime,
            "FractionalNftVault: preSale not Started"
        );

        require(item.preSaleEndTime > block.timestamp, "FractionalNftVault: preSale Ended");

        require(
            _totalAmount >= item.unitPrice,
            "FractionalNftVault: provided currency amount is not enough"
        );

        uint256 _shares = _totalAmount/ item.unitPrice;

        (uint256 companyAmount, uint256 creatorAmount, uint256 liquidityAmount) = calculateShare(_totalAmount);
        _transferAmount(item.paymentIndx, msg.sender, owner(), companyAmount);
        _transferAmount(item.paymentIndx, msg.sender, item.nftOwner, creatorAmount);
        _transferAmount(item.paymentIndx, msg.sender, liquidityWallet, liquidityAmount);

        Shares(item.shareToken).safeTransfer(msg.sender, _shares * 1 ether);

        emit ShareSold(
            msg.sender,
            _shares,
            item.unitPrice,
            item.nftId,
            item.shareToken,
            block.timestamp
        );
    }

    // function _transferAmount(uint8 _indx, address _msgSender, address receiver, uint256 amount) internal returns(bool){
    //   return   IERC20Upgradeable(paymentToken[_indx]).transferFrom(_msgSender, receiver, amount);
    // }

       function _transferAmount(uint8 _indx, address _msgSender, address receiver, uint256 amount) internal {
        IERC20Upgradeable(paymentToken[_indx]).safeTransferFrom( _msgSender, receiver, amount);
      
    }

    function calculateShare(uint256 _amount) public view returns(uint256, uint256, uint256) {
        (uint16 companyRatio, uint16 creatorRatio, uint16 liquidityRatio) = getShareRatio();
         uint256 companyA = (_amount / 1000) * companyRatio;
         uint256 creatorA = (_amount / 1000) * creatorRatio;
         uint256 liquidityA = (_amount / 1000) * liquidityRatio;

         return(companyA, creatorA, liquidityA);
    }

    function claimRemainingShareToken(uint256 _id) external override {
        Item storage item = vaults[_id];
        require(msg.sender == item.nftOwner, "FractionalNftVault: nft owner only");
        uint256 unSoldAmount = Shares(item.shareToken).balanceOf(address(this));

        require(unSoldAmount > 0, "FractionalNftVault: sold out");
        require(block.timestamp > item.preSaleEndTime, "FractionalNftVault: preSale not finished");
        Shares(item.shareToken).safeTransfer(msg.sender, unSoldAmount);

        emit ClaimUnSoldToken(msg.sender, unSoldAmount, block.timestamp);
    }

    function setPaymentToken(uint8 index, address _paymentToken) public onlyOwner {
        require(index != 0,"FractionalNftVault: index should not be 0");
        paymentToken[index] = _paymentToken;
    }

    function addWhitelist(address _whiteListAddress) external onlyOwner {
        isWhitelisted[_whiteListAddress] = true;
        emit whitelistAdded(_whiteListAddress);
    }

    function addBlacklist(address _blackListAddress) external onlyOwner {
        isWhitelisted[_blackListAddress] = false;
        emit blacklistAdded(_blackListAddress);
    }

    function setShareRatio(uint16 _companyShare, uint16 _creatorShare, uint16 _liquidityShare) external onlyOwner {
        require(_companyShare + _creatorShare + _liquidityShare == 1000, "Sum must be equal to 1000 pt");

        companyShare = _companyShare;
        creatorShare = _creatorShare;
        liquidityShare = _liquidityShare;
        emit ShareRatioChanged(companyShare, creatorShare,liquidityShare );
    }

    function getShareRatio() public view returns(uint16, uint16, uint16) {
        return (companyShare, creatorShare, liquidityShare);
    }

    function getVault(uint256 _id) external view returns(Item memory) {
        return vaults[_id];
    }

    function getPaymentToken(address _user) external view returns(bool) {
        return isWhitelisted[_user];
    }

    function setOwnerRoyality(uint16 _royality) external onlyOwner{
            _ownerRoyalty = _royality;
            emit royalityChanged(_royality);
    }

    function setSharesAddress(address _newAddress) external onlyOwner{
        sharesAddress = _newAddress;
    }

    function checkaddress() public returns(address){
        Shares __token = new Shares();
        return address(__token);
    }

      function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}