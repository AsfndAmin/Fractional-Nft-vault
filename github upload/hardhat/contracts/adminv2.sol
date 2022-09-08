// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./Nft.sol";

contract adminContractv2 is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
    
{
    function initialize() external initializer {
        __Ownable_init();

    } 

       function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function deployNewNft(string memory _name, string memory _symbol, string memory _baseuri, uint256 _totalSupply, address _payment)
    external
    {
                Nft newContract = new Nft();
        newContract.initialize(
            _name,
            _symbol,
            _baseuri,
            _totalSupply,
            _payment

        );
    }


}