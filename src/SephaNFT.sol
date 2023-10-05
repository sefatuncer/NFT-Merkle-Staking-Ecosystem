// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
/**
 * @title SephaNFT Smart Contract
 *  @notice This contract handles the SephaNFT token logic.
 *  @author Sefa Tuncer
 */

contract SephaNFT is ERC721, Ownable2Step, IERC2981 {
    using BitMaps for BitMaps.BitMap;

    bytes32 public merkleRoot;
    mapping(address => uint256) private _owners;
    BitMaps.BitMap private _claimedBitmap;
    uint256 public _tokenIdCounter = 0;

    mapping(uint256 => string) private _tokenURIs;

    /// @notice Maximum supply for the SephaNFT.
    uint256 public constant MAX_SUPPLY = 20;

    /// @notice Royalty rate for each SephaNFT transaction.
    uint256 public constant ROYALTY_RATE = 250; // 2.5%

    string private _baseTokenURI;

    // Events
    event MintedNFT(address recipient, uint256 tokenId);

    /// @notice Initializes the contract with a given Merkle root.
    /// @param _merkleRoot The Merkle root for verifying token ownership.
    constructor(bytes32 _merkleRoot) ERC721("SephaNFT", "STR") Ownable(msg.sender) {
        _baseTokenURI = "https://www.sephanft.com/sephanft";
        merkleRoot = _merkleRoot;
    }

    /// @dev Returns how much royalty is owed and to whom, based on a sale price.
    /// @param salePrice The sale price of the NFT.
    /// @return receiver The address of the royalty receiver.
    /// @return royaltyAmount The amount to be paid as royalty.
    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = owner();
        royaltyAmount = (salePrice * ROYALTY_RATE) / 10000;
    }

    /// @dev Sets the URI for a given token ID
    /// @param tokenId The token ID to set its URI.
    /// @param _tokenURI The URI to associate with `tokenId`.
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _requireMinted(tokenId);
        _tokenURIs[tokenId] = _tokenURI;
    }

    /// @dev Returns the base URI set.
    /// @return the base URI.
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /// @dev Returns the URI for a given token ID.
    /// @param tokenId the token ID to query.
    /// @return the token URI of `tokenId`.
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    /// @notice Mints a new NFT.
    /// @dev Only the owner can mint new tokens.
    /// @param recipient The address that will own the minted token.
    function mintNFT(address recipient) public onlyOwner {
        require(_tokenIdCounter < MAX_SUPPLY, "Maximum NFT supply reached");

        _mint(recipient, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, "");
        emit MintedNFT(recipient, _tokenIdCounter);
        _tokenIdCounter++;
        _owners[recipient]++;
    }

    /// @notice Mints a new NFT with a discount.
    /// @dev Only unclaimed tokens can be minted with a discount.
    /// @param proof The Merkle proof for the discount.
    function discountedMintNFT(bytes32[] calldata proof) public {
        require(_tokenIdCounter < MAX_SUPPLY, "Maximum NFT supply reached");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");
        require(!_claimedBitmap.get(_tokenIdCounter), "Discount already claimed");

        _mint(msg.sender, _tokenIdCounter);
        //_safeMint(msg.sender, _tokenIdCounter, "");
        emit MintedNFT(msg.sender, _tokenIdCounter);
        _claimedBitmap.set(_tokenIdCounter);
        _tokenIdCounter++;
        _owners[msg.sender]++;
    }

    /// @notice Checks if an address owns any NFT.
    /// @param account The address to check.
    /// @return True if the address owns an NFT, false otherwise.
    function isNFTOwner(address account) public view returns (bool) {
        return _owners[account] > 0;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }
}
