// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
* @author Zig Balthazar(Pouya) @Zig.balthazar
*
*
* @notice The contract you are considering is designed for
*    the collection of Frenchie Friends Club and has been
*    implemented and developed in accordance with the needs of the project
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract BillieNFT is Ownable,ERC721 {

    constructor(uint256 _MaxSupply) ERC721("Bille NFT Collection","BIL"){
        Max_Supply = _MaxSupply;
    }

    receive() external payable {}
    fallback() external payable {}

    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _ID;

    uint256 public WhiteList_Sale_Price;
    uint256 public Public_Sale_Price;
    uint256 public Max_public_Mint_Amount;
    uint256 public Max_WhiteList_Mint_Amount;
    uint256 public Supply;
    uint256 public Max_Supply;
    uint256 public Total_Mint_Amount;
    bool public WhiteList_Sale_Status;
    bool public Public_Sale_Status;
    bytes32 private WhiteList_Root;

 

    mapping(address => uint256) WhiteList_Minted_Amount;
    mapping(address => uint256) Public_Minted_Amount;

    //EVENTS
    event Event_Mint(address _Recipient,uint256 _IDs,string _Phase);
    event Event_Supply(uint256 _Supply);

    //Public Functions
    function Mint(address _Recipient, uint256 _Amount) payable  public returns(bool){
            require(Public_Sale_Status==true,"Public Sale is Disable!");
        if (msg.sender != owner()){
            require(_Amount <= Max_public_Mint_Amount && _Amount>0 && _Amount.add(Supply)<=Max_Supply,"There is a problem with the _Amount value");
            require(Public_Minted_Amount[_Recipient].add(_Amount)<=Max_public_Mint_Amount,"");
            require(Public_Minted_Amount[_Recipient].add(WhiteList_Minted_Amount[_Recipient]).add(_Amount)<=Total_Mint_Amount,"Total mint ERROR!!!");
            require(msg.value >= _Amount*Public_Sale_Price,"The amount sent to the contract is incorrect.");
        }
        for (uint256 i = 1; i <= _Amount; i++){
            _safeMint(_Recipient,_ID.current(),"");
            emit Event_Mint(_Recipient,_ID.current(),"Public_Mint");
            Public_Minted_Amount[_Recipient] +=1;
            _ID.increment();
            Supply++;
        }
        return true;
    }

    function WhiteListMint(bytes32[] calldata _Proof, uint256 _Amount) payable public returns(bool){
            require(WhiteList_Sale_Status==true,"WhiteList Sale is Disable!");
            require(_Amount <= Max_WhiteList_Mint_Amount && _Amount>0 && _Amount.add(Supply)<=Max_Supply,"There is a problem with the _Amount value");
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(MerkleProof.verify(_Proof,WhiteList_Root,leaf),"This address does not exist in the whitelist!");
            require(WhiteList_Minted_Amount[msg.sender].add(_Amount)<=Max_WhiteList_Mint_Amount,"Mint Limitations!");
            // require(WhiteList_Minted_Amount[msg.sender]+_Amount<=
        if(msg.sender!=owner()){
            require(Public_Minted_Amount[msg.sender].add(WhiteList_Minted_Amount[msg.sender]).add(_Amount)<=Total_Mint_Amount,"Total mint ERROR!!!");
            require(msg.value >= _Amount*WhiteList_Sale_Price,"The amount sent to the contract is incorrect."); 
        }
        for (uint256 i = 1; i <= _Amount; i++){
            _safeMint(msg.sender,_ID.current(),"");
            emit Event_Mint(msg.sender,_ID.current(),"WhiteList_Mint");
            WhiteList_Minted_Amount[msg.sender] +=1;
            _ID.increment();
            Supply++;
        }
        return true;
    }


    function totalSupply() public returns(uint256){
        emit Event_Supply(Supply);////////////////////////////////
        return Supply;
    }

    //Owner Functions
    function SetWhiteListSalePrice(uint256 _NewPrice) public onlyOwner{
        WhiteList_Sale_Price = _NewPrice;
    }

    function SetPublicSalePrice(uint256 _NewPrice) public onlyOwner{
        Public_Sale_Price = _NewPrice;
    }

    function WhiteListSaleStatusChanger(bool _State) public onlyOwner{
        WhiteList_Sale_Status = _State;
    }

    function PublicSaleStatusChanger(bool _State) public onlyOwner{
        Public_Sale_Status = _State;
    }

    function ChangeRevealStatus(bool _State) public onlyOwner{
        Is_Reveal = _State;
    }

    function SetMaxPublicMintAmount(uint256 _Amount) public onlyOwner{
        Max_public_Mint_Amount = _Amount;
    }
    
    function SetWhiteListMaxMintAmount(uint256 _Amount) public onlyOwner{
        Max_WhiteList_Mint_Amount = _Amount;
    }
        function SetTotalMintAmount(uint256 _Amount) public onlyOwner{
        Total_Mint_Amount = _Amount;
    }
        function SetWhiteListRoot(bytes32 _Root) public onlyOwner{
        WhiteList_Root = _Root;
    }
    
    function Withdrawal() payable public onlyOwner{
        (bool sent,) = owner().call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

 
