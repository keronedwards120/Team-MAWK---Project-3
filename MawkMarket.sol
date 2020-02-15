pragma solidity >=0.4.22 <0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
import "./MawkAuction.sol";
import "./Seller.sol";
import "./IBidder.sol";
import "./ISeller.sol";
import "./ICommon.sol";

 
contract MawkMarket is IBidder,ICommon,ERC721Full,Ownable {
    // Construct the token  name and add counters to create each token_id
    constructor() ERC721Full("MawkMarket", "MAWK") public {}
    using Counters for Counters.Counter;

    Counters.Counter token_ids;
    Counters.Counter item_ids;
    address payable foundation_address = msg.sender;
    
    // Mapping to create lists and and auction 
    mapping(uint => MawkAuction) public auctions;
    mapping(address => Seller) public seller_list;
    mapping(uint => Item) public item_list;


    modifier sellerRegistered(address payable _address) {
        require(seller_list[_address].isExist(),"Seller not registered!");
        _;
    }
    
    modifier itemRegistered(uint token_id){
        require(_exists(token_id),"Item not registered!");
        _;
    }
    //Events for functions 
    event RegisterItem (uint token_id, address owner, string uri);
    event Verify(uint token_id);

    //Allow public to create auction 
    function createAuction(uint token_id, address payable seller) public {
        auctions[token_id] = new MawkAuction(seller);
    }
    //Allow only owner to end the auction
    function endAuction(uint token_id) public onlyOwner itemRegistered(token_id) {
        MawkAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }
    //Auction has ended function public interface
    function auctionEnded(uint token_id) public view returns(bool) {
        MawkAuction auction = auctions[token_id];
        return auction.ended();
    }
    //Allow for highest bid to be publicly vieable to front end
    function highestBid(uint token_id) public view itemRegistered(token_id) returns(uint) {
        MawkAuction auction = auctions[token_id];
        return auction.highestBid();
    }
    //Pending returns to allow withdrawl, publicly on front-end
    function pendingReturn(uint token_id, address sender) public view itemRegistered(token_id) returns(uint) {
        MawkAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }
    //Bidder function from Auction house - front-end
    function bid(uint token_id) public payable itemRegistered(token_id) {
        MawkAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }
    //Auction House can verify the item so it can be sold  only owner - front end
    function verify (item_id, uri) public onlyOwner {
        MawkAuction auction = auctions[token_id];
        auction.verify();
        emit Verify(item_id, uri);
    }
    //Verifycheck for public - front end 
     function verifycheck (uint token_id) public view returns (bool){
        MawkAuction auction = auctions[token_id];
        return auction.verifycheck();
    }

// Function register Items - front-end
    function registerItems(string memory uri, uint value) public payable {
        item_ids.increment();
        uint item_id = item_ids.current();
        item_list[item_id] = Item(msg.sender, uri, value);
        _setTokenURI(item_id, uri);
        createAuction(item_id, msg.sender);
        emit RegisterItem(token_id, msg.sender, uri);
      
    }
}
