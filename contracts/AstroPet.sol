// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AstroPet is ERC721URIStorage, Ownable, ReentrancyGuard {
    // Existing token and event data
    uint256 private _tokenIdCounter;
    mapping(uint256 => string) public petOrigins;
    mapping(address => uint256) public addressMintCount;
    uint256 public maxMintPerAddress = 5;

    // Event management structures
    struct CommunityEvent {
        uint256 eventId;
        string eventName;
        string eventDescription;
        uint256 startTime;
        uint256 endTime;
        address[] participants;
        bool isActive;
    }

    uint256 public eventCounter;
    mapping(uint256 => CommunityEvent) public events;
    mapping(address => uint256) public rewards;
    mapping(address => string) public userPreferences;

    // Events
    event EventCreated(uint256 indexed eventId, string eventName, uint256 startTime, uint256 endTime);
    event EventParticipated(uint256 indexed eventId, address participant);
    event RewardDistributed(address indexed participant, uint256 amount);
    event AstroPetMinted(uint256 tokenId, address owner, string tokenURI, string originChain);
    event AstroPetTransferred(uint256 tokenId, address from, address to, string destinationChain);

    constructor() ERC721("AstroPet", "ASTP") {
        _tokenIdCounter = 1;
    }

    // Modifier to enforce mint limit per address
    modifier canMint(address to) {
        require(addressMintCount[to] < maxMintPerAddress, "Mint limit reached for this address");
        _;
    }

    // Function to mint AstroPet
    function mintAstroPet(address to, string memory _tokenURI, string memory _originChain) 
        external onlyOwner nonReentrant canMint(to) 
    {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        petOrigins[tokenId] = _originChain;
        emit AstroPetMinted(tokenId, to, _tokenURI, _originChain);
        _tokenIdCounter++;
        addressMintCount[to]++;
    }

    // Event management functions
    function createEvent(string memory name, string memory description, uint256 startTime, uint256 endTime) external onlyOwner {
        require(startTime < endTime, "Invalid event time");
        
        // Initialize an empty array of addresses
        address[] memory participants = new address[](0);
        
        events[eventCounter] = CommunityEvent({
            eventId: eventCounter,
            eventName: name,
            eventDescription: description,
            startTime: startTime,
            endTime: endTime,
            participants: participants,
            isActive: true
        });
        
        emit EventCreated(eventCounter, name, startTime, endTime);
        eventCounter++;
    }

    function participateInEvent(uint256 eventId) external {
        CommunityEvent storage communityEvent = events[eventId];
        require(communityEvent.isActive, "Event is not active");
        require(block.timestamp >= communityEvent.startTime && block.timestamp <= communityEvent.endTime, "Event not in progress");

        communityEvent.participants.push(msg.sender);
        emit EventParticipated(eventId, msg.sender);
    }

    // Reward management
    function distributeRewards(address participant, uint256 amount) external onlyOwner {
        rewards[participant] += amount;
        emit RewardDistributed(participant, amount);
    }

    // Function to deposit ETH into the contract
function depositETH() external payable onlyOwner {
    require(msg.value > 0, "Must send some ETH");
}

// Function to check the contract's ETH balance
function getContractBalance() external view returns (uint256) {
    return address(this).balance;
}


   function claimRewards() external nonReentrant { 
    uint256 reward = rewards[msg.sender];
    require(reward > 0, "No rewards to claim");

    // Reset the reward balance before transferring to prevent reentrancy attacks
    rewards[msg.sender] = 0;

    // Transfer ETH to the caller
    (bool success, ) = payable(msg.sender).call{value: reward}("");
    require(success, "Transfer failed");
}


    // User data preference management
    function setUserPreference(string memory preference) external {
        userPreferences[msg.sender] = preference;
    }

    function getUserPreference(address user) external view returns (string memory) {
        return userPreferences[user];
    }
}