pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <=0.6.1;

interface IMawkMarket{
    function createAuction(uint token_id) external;
    function registerSeller(address payable_benefiary) external;
    function registerItems(address payable owner,  string calldata uri, uint value) external;
    function endAuction(uint token_id) external;
    function auctionEnded(uint token_id) external view returns(bool);
    function highestBid(uint token_id) external view returns(uint);
    function pendingReturn(uint token_id, address sender) external view returns(uint);
    function bid(uint token_id) external payable;
}