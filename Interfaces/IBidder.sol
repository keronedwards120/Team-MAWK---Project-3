pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <=0.6.1;


interface IBidder {
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    function bid(address payable sender) external payable;
    function withdraw() external returns (bool);
    function pendingReturn(address sender) external view returns (uint);
    function auctionEnd() external;
}
