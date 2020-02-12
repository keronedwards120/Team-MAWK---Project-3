pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <=0.6.1;

interface ICommon{
    struct Item{
        address payable owner;
        string uri;
        uint value;
    }
}