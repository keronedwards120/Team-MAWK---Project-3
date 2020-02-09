pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <=0.6.1;


interface Ibidder {
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    function bid(address payable sender) public payable;
    function withdraw() public returns (bool);
    function pendingReturn(address sender) public view returns (uint);
    function auctionEnd() public;
    
}
