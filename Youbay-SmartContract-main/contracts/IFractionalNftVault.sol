//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
interface IFractionalNftVault {
     function fractionalizeNft(
        string calldata _name,
        string calldata _symbol,
        address _token,
        uint256 _id,
        uint256 _supply,
        uint256 _listPrice,
        uint256 _preSaleStartTime,
        uint16 _ownerRoyalty,
        uint8 _paymentIndx
    ) external ;

        function buyShare(
        uint256 _id,
        uint256 _shares,
        uint256 _totalAmount
    ) external ;

    function claimRemainingShareToken(uint256 _id) external;

     event ShareSold(
        address buyer,
        uint256 shareAmount,
        uint256 currencyAmount,
        address nftAddress,
        uint256 nftId,
        address shareToken,
        uint256 buyTime
    );

    event ClaimUnSoldToken(address nftOwner, uint256 unSoldAmount,uint256 claimTime);

    event FractionalizeNft(
        address nftOwner,
        uint256 share,
        uint256 unitPrice,
        address nftAddress,
        uint256 nftId,
        address shareToken,
        uint256 preSaleStartTime,
        uint256 preSaleEndTime
    );

    
}