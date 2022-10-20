//SPDX-License-Identifier: un-licence
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


contract Shares is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable  {
    uint256 private supply;
    uint256 private ownerRoyalty;
    uint256 private platformFee;
    address private platformAddress;
    address private ownerAddress;
    uint256 private preSaleEndTime;

     
  /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _supply,
        uint256 _ownerRoyalty,
        uint256 _platformFee,
        address _ownerAddress,
        uint256 _amountLiquidityWallet,
        uint256 _amountsender,
        address _liquidtyWallet,
        uint256 _preSaleEndTime
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __Ownable_init();
        __UUPSUpgradeable_init();
        transferOwnership(_ownerAddress);
        supply = _supply;
        platformAddress = msg.sender;
        platformFee = _platformFee;
        ownerRoyalty = _ownerRoyalty;
        ownerAddress = _ownerAddress;
        preSaleEndTime = _preSaleEndTime;
        _mint(_liquidtyWallet, _amountLiquidityWallet);
        _mint(msg.sender, _amountsender);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address msgSender = msg.sender;
        if (msgSender == ownerAddress ) {
            _transfer(msgSender, recipient, amount);
        } 
        if (msgSender == platformAddress ) {
            _transfer(msgSender, recipient, amount);
        } 
        
        else {
            require(block.timestamp > preSaleEndTime, "Shares: cannot transfer before sale ends");
            uint256 _ownerFee = (amount * ownerRoyalty) / 1000;
            uint256 _platformFee = (amount * platformFee) / 1000;
            uint256 _amount = amount - (_ownerFee + _platformFee);
            
            _transfer(msgSender, ownerAddress, _ownerFee);
            _transfer(msgSender, platformAddress, _platformFee);
            _transfer(msgSender, recipient, _amount);

        }
        return true;
    }

    function getOwnerRoyalty() external view returns (uint256) {
        return ownerRoyalty;
    }

    function totalSupply() public view override returns (uint256) {
        return supply;
    }

    function getOwnerAddress() external view returns (address) {
        return ownerAddress;
    }

      function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}