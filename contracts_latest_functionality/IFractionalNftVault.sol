//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
interface IFractionalNftVault {
     function fractionalizeNft(
        string calldata _name,
        string calldata _symbol,
        uint256 _supply,
        uint256 _listPrice,
        uint256 _preSaleStartTime,
        address _router,
        uint8 _paymentIndx
    ) external ;

        function buyShare(
        uint256 _id,
        uint256 _totalAmount
    ) external ;

    function claimRemainingShareToken(uint256 _id) external;

     event ShareSold(
        address buyer,
        uint256 shareAmount,
        uint256 currencyAmount,
        uint256 nftId,
        address shareToken,
        uint256 buyTime
    );
     event Response(bool success, bytes  data);
      event royalityChanged(uint16 _royality);
      event companyAddressChanged(address _comapnyAddress);

      event ShareRatioChanged(uint16 _companyShare, uint16 _creatorShare, uint16 _liquidityShare);

    event ClaimUnSoldToken(address nftOwner, uint256 unSoldAmount,uint256 claimTime);

    event whitelistAdded(address _whiteListAddress);

    event blacklistAdded(address _blackListAddress);

    event FractionalizeNft(
        address nftOwner,
        uint256 share,
        uint256 unitPrice,
        uint256 nftId,
        address shareToken,
        uint256 preSaleStartTime,
        uint256 preSaleEndTime,
        address uniSwapPair
    );

    
}