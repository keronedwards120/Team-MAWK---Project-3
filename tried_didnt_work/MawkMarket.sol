pragma solidity >=0.4.22 <=0.6.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
import "./MawkAuction.sol";
import "./Seller.sol";
import "./IBidder.sol";
import "./ISeller.sol";
import "./ICommon.sol";

contract MawkMarket is IBidder,ICommon,ERC721Full,Ownable {
    constructor() ERC721Full("MawkMarket", "MAWK") public {}
    using Counters for Counters.Counter;

    Counters.Counter token_ids;
    Counters.Counter item_ids;
    address payable foundation_address = msg.sender;

    mapping(uint => MawkAuction) public auctions;
    mapping(address => Seller) public seller_list;
    mapping(uint => Item) public item_list;
    
    event Verify(uint item_id, string uri);


    modifier sellerRegistered(address payable _address) {
        require(seller_list[_address].isExist(),"Seller not registered!");
        _;
    }

    modifier itemRegistered(uint token_id){
        require(_exists(token_id),"Item not registered!");
        _;
    }

    function createAuction(uint token_id, address payable seller) public {
        auctions[token_id] = new MawkAuction(seller);
    }

    function endAuction(uint token_id) public onlyOwner itemRegistered(token_id) {
        MawkAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        MawkAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view itemRegistered(token_id) returns(uint) {
        MawkAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view itemRegistered(token_id) returns(uint) {
        MawkAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable itemRegistered(token_id) {
        MawkAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }

    // register seller
    // function registerSeller(address payable _beneficiary) internal sellerRegistered(_beneficiary) {
    //     seller_list [_beneficiary] = new Seller(_beneficiary);
    // }

    // function registerBidder(address payable _beneficiary ) internal bidderRegistered(payable _beneficiary) {
    //     bidder_lis _beneficiary]=new Bidder(payable _beneficiary);
    // }
    function verify (item_id, uri) public onlyOwner {
        emit Verify(item_id, uri);
    }
    


// Function register Items
    function registerItems(string memory uri, uint value) public payable {
        //registerSeller(msg.sender);
        item_ids.increment();
        uint item_id = item_ids.current();
        item_list[item_id] = Item(msg.sender, uri, value);
        //_mint(msg.sender, item_id);
        _setTokenURI(item_id, uri);
        createAuction(item_id, msg.sender);
      
    }
}
