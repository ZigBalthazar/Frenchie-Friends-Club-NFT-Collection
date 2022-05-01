// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/**
 * @title Frenchie Friends Club contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */

// URI // set URI

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FFC_NFT is ERC721, Ownable, ReentrancyGuard {
    constructor(
        string memory _Name,
        string memory _Symbol,
        uint256 _TotalSupply,
        uint256 _TotalWhiteListSupply
    ) ERC721(_Name, _Symbol) {
        TotalSupply = _TotalSupply;
        TotalWhiteListSupply = _TotalWhiteListSupply;
    }

    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _ID;

    uint256 public PublicSalePrice = 0.001 ether;
    uint256 public WhiteListSalePrice = 0.0001 ether;

    uint256 public MaxTotalMintAmount = 4;
    uint256 public MaxWhiteListMintAmount = 2;
    uint256 public MaxPublicMintAmount = 2;

    uint256 public TotalSupply;
    uint256 public TotalWhiteListSupply;
    uint256 public Supply;

    mapping(address => uint256) WhiteListMinted;
    mapping(address => uint256) PublicMinted;

    bool public WhiteListSaleStatus; 
    bool public PublicSaleStatus;

    bytes32 WhiteListRoot; 

    error DirectMintFromContractNotAllowed();
    error ZeroAddressCantMint();
    error PublicSaleInactive();
    error WhiteListSaleInactive();
    error ExceedWhiteListMintAmount();
    error ExceedMaxPublicMintAmount();
    error InsufficientETHSent();
    error ExceedsAllocatedForWhiteListSale();
    error NotOnWhitelist();
    error ExceedsMaxSupply();
    error WithdrawalFailed();
    error ExceedTotalMintAmount();
    error AmountCantBeZero();

    // event PublicMinted();
    // event WhiteListMinted();

    modifier callerIsUser() {
        if (tx.origin != msg.sender) revert DirectMintFromContractNotAllowed();
        _;
    }

    function Mint(uint256 _Amount) public payable callerIsUser nonReentrant {
        if (!PublicSaleStatus) revert PublicSaleInactive();

        if (Supply.add(_Amount) > TotalSupply) revert ExceedsMaxSupply();

        if (_Amount <= 0) revert AmountCantBeZero();

        if (msg.sender != owner()) {
            if (
                PublicMinted[msg.sender].add(WhiteListMinted[msg.sender]).add(
                    _Amount
                ) > MaxTotalMintAmount
            ) revert ExceedTotalMintAmount();

            if (PublicMinted[msg.sender].add(_Amount) > MaxPublicMintAmount)
                revert ExceedMaxPublicMintAmount();

            if (msg.value < PublicSalePrice.mul(_Amount))
                revert InsufficientETHSent();
        }

        PublicMinted[msg.sender] += _Amount;

        for (uint256 index = 1; index <= _Amount; index++) {
            Supply++;
            _safeMint(msg.sender, _ID.current(), "");
            _ID.increment();
        }
        // emit PublicMint();
    }

    function WhiteListMint(uint256 _Amount, bytes32[] calldata _Proof)
        public
        payable
        callerIsUser
        nonReentrant
    {
        if (!WhiteListSaleStatus) revert WhiteListSaleInactive();

        bytes32 _leaf = keccak256(abi.encodePacked(msg.sender));
        if (!MerkleProof.verify(_Proof, WhiteListRoot, _leaf))
            revert NotOnWhitelist();

        if (Supply.add(_Amount) > TotalSupply) revert ExceedsMaxSupply();
        if (_Amount <= 0) revert AmountCantBeZero();
        if (
            PublicMinted[msg.sender].add(WhiteListMinted[msg.sender]).add(
                _Amount
            ) > MaxTotalMintAmount
        ) revert ExceedTotalMintAmount();
        if (WhiteListMinted[msg.sender].add(_Amount) > MaxWhiteListMintAmount)
            revert ExceedWhiteListMintAmount();
        if (msg.value < WhiteListSalePrice.mul(_Amount))
            revert InsufficientETHSent();

        WhiteListMinted[msg.sender] += _Amount;

        for (uint256 index = 1; index <= _Amount; index++) {
            Supply++;
            _safeMint(msg.sender, _ID.current(), "");
            _ID.increment();
        }
    }

    function totalSupply() public view returns (uint256) {
        return Supply;
    }

    //Owner Functions
    function ToggleWhitelistSaleStatus() public onlyOwner {
        WhiteListSaleStatus = !WhiteListSaleStatus;
    }

    function TogglePublicSaleStatus() public onlyOwner {
        PublicSaleStatus = !PublicSaleStatus;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        WhiteListRoot = _merkleRoot;
    }

        function withdraw() payable public onlyOwner nonReentrant{
        (bool sent,) = owner().call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }


}
