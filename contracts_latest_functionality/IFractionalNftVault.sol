//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IFractionalNftVault {

    event ShareSold(
        address buyer,
        address shareToken,
        uint256 shareAmount,
        uint256 currencyAmount,
        uint256 nftId,
        uint256 buyTime
    );
    event CreatorFeeUpdated(uint16 _royality);
    event CompanyAddressChanged(address _comapnyAddress);
    event ShareRatioChanged(uint16 _companyShare, uint16 _creatorShare, uint16 _liquidityShare);
    event ClaimUnSoldToken(address nftOwner, uint256 unSoldAmount,uint256 claimTime);
    event WhitelistAdded(address[] _whiteListAddress);
    event BlacklistAdded(address[] _blackListAddress);
    event ServiceFeeUpdated(uint256);
    event FractionalizeNft(
        address nftOwner,
        address uniSwapPair,
        address shareToken,
        uint256 share,
        uint256 unitPrice,
        uint256 nftId,
        uint256 preSaleStartTime,
        uint256 preSaleEndTime
    );

    function fractionalizeNft(
        string calldata _name,
        string calldata _symbol,
        address _router,
        uint256 _supply,
        uint256 _listPrice,
        uint256 _preSaleStartTime,
        uint8 _paymentIndx
    ) external;

    function buyShare(
        uint256 _id,
        uint256 _totalAmount
    ) external;

    function claimRemainingShareToken(uint256 _id) external;
}
