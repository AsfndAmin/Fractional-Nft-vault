//SPDX-License-Identifier: un-licence
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Shares is ERC20, AccessControl {
    uint256 private supply;
    uint256 private creatorFee;
    uint256 private platformFee;
    address private platformAddress;
    address private ownerAddress;
    address private liquidtyWallet;
    uint256 private preSaleEndTime;
    uint16 private base = 10000;

    using SafeMath for uint256;
     
 constructor(  
        string memory _name,
        string memory _symbol,
        uint256 _supply,
        uint256 _creatorFee,
        uint256 _platformFee,
        address _ownerAddress,
        uint256 _amountLiquidityWallet,
        uint256 _amountsender,
        address _liquidtyWallet,
        uint256 _preSaleEndTime
        ) ERC20(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        supply = _supply;
        platformAddress = msg.sender;
        platformFee = _platformFee;
        creatorFee = _creatorFee;
        ownerAddress = _ownerAddress;
        liquidtyWallet = _liquidtyWallet;
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
             require(block.timestamp > preSaleEndTime, "Shares: cannot transfer before sale ends");
            _transfer(msgSender, recipient, amount);
        } 
        else if (msgSender == platformAddress || msgSender == liquidtyWallet ) {
            _transfer(msgSender, recipient, amount);
        } 
        
        else {
            require(block.timestamp > preSaleEndTime, "Shares: cannot transfer before sale ends");
            (uint256 _ownerFee, uint256 _platformFee, uint256 _amount) = calculateFee(amount);
            
            _transfer(msgSender, ownerAddress, _ownerFee);
            _transfer(msgSender, platformAddress, _platformFee);
            _transfer(msgSender, recipient, _amount);

        }
        return true;
    }

    function transferFrom(address from, address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool) 
    {
        address msgSender = msg.sender;
        _spendAllowance(from, msgSender, amount);

         if (from == ownerAddress ) {
             require(block.timestamp > preSaleEndTime, "Shares: cannot transfer before sale ends");
            _transfer(from, recipient, amount);
        } 
        else if (from == platformAddress || msgSender == liquidtyWallet ) {
            _transfer(from, recipient, amount);
        } 
         
        else {
            require(block.timestamp > preSaleEndTime, "Shares: cannot transfer before sale ends");
             (uint256 _ownerFee, uint256 _platformFee, uint256 _amount) = calculateFee(amount);
            
            _transfer(from, ownerAddress, _ownerFee);
            _transfer(from, platformAddress, _platformFee);
            _transfer(from, recipient, _amount);

        }
        return true;
    }

        //calculates the fee for the given amount    
    function calculateFee(uint256 _amount) public view returns(uint256, uint256, uint256) {
            require(_amount >= base," amount too low");
            uint256 _ownerFee = (amount.mul(creatorFee)).div(base);
            uint256 _platformFee = (amount.mul(platformFee)).div(base);
            uint256 _amount = amount.sub(_ownerFee.add(_platformFee));
            return(_ownerFee, _platformFee, _amount);
    }

    function getcreatorFee() external view returns (uint256) {
        return creatorFee;
    }

    function totalSupply() public view override returns (uint256) {
        return supply;
    }

    function getOwnerAddress() external view returns (address) {
        return ownerAddress;
    }
}
