// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;


contract SimpleStorage {
    // Basic Types: boolen, uint, int, address, bytes
  bool hasFavoriteNumber = true;
  uint256 favoriteNumber =  88;
  int256 favoriteInt = -99;
  string favoriteNumberIntext = "eighty-eight";
  address myAddress = 0xD1Bfce9EA8ee1e6C4168D2E0E7402A681fFE5Fb1;
  bytes23 favoriteBytes32 ="cat";

  //uint256 favoritNumber; //0 
  // favoritNumber gets initialized to 0 if no value is given 

}


contract SimpleStorages {

    uint256 favoriteNumber;

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

}
// public : visible externally and internally 
// private : only visible in the current contract 
// external : only visible externally (only for function) -i.e can only be message-called(via.func)
// internal :only visible internally

contract PublicStorages {

    uint256 public  favoriteNumber; // Store The favoriteNumber


    function store(uint256 _favoriteNumber) public { // Update The favoriteNumber
        favoriteNumber = _favoriteNumber;
    }
    // view, pure
    function retrieve() public view returns(uint256) { //  View the favoriteNumber
      return favoriteNumber;
    }

}


// SImple Storage Solidity Arrays & Structs


// contract complexStore {

//     uint256   myFavoriteNumber;

//     //   uint256[]  favoriteNumbers;
//     struct Person {
//       uint256 favoriteNumber;
//       string name;
//     }

//     Person public Arjun = Person({favoriteNumber: 7, name: "Arjun"});
//     Person public mariah = Person({favoriteNumber: 5, name: "mariah"});
//     Person public jon = Person({favoriteNumber: 56, name: "jon"});
//     Person public krish = Person({favoriteNumber: 67, name: "krish"});
//     Person public patrick = Person({favoriteNumber: 90, name: "patrick"});



//     function store(uint256 _favoriteNumber) public {
//         myFavoriteNumber = _favoriteNumber;
//     }
//     // view, pure
//     function retrieve() public view returns(uint256) {
//       return myFavoriteNumber;
//     }

// }


contract complexStore {

    uint256   myFavoriteNumber;

    //   uint256[]  favoriteNumbers;
    struct Person {
      uint256 favoriteNumber;
      string name;
    }
     

     // dynamic array
     // static array
    Person[] public listOfPeople; //[]



    function store(uint256 _favoriteNumber) public {
        myFavoriteNumber = _favoriteNumber;
    }
    // view, pure
    function retrieve() public view returns(uint256) {
      return myFavoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
      // Person memory newPerson = Person(_favoriteNumber, _name);
      // listOfPeople.push(newPerson);
      listOfPeople.push(Person(_favoriteNumber, _name));
    }

}



// 18-02-2025



// The ENM can read and Write to several places  

//  write & Read:               Write(not read)


//  Stack                       * Logs
//  Memory                      * Read(not Write)
//  Storage                     * Transaction data(&Blobhash)
//  Transient Storage           * Chain Data
//  Calldata                    * Gas data
//  Code                        * Program Counter
//  Returndata                  * (other)



// Basic Soildity Mappings
   // mapping(string => uint256) public nameToFavoriteNumber;

contract Store {

    uint256   myFavoriteNumber;

    struct Person {
      uint256 favoriteNumber;
      string name;
    }
     
    Person[] public listOfPeople; //[]

    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public {
        myFavoriteNumber = _favoriteNumber;
    }
    // view, pure
    function retrieve() public view returns(uint256) {
      return myFavoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
      listOfPeople.push(Person(_favoriteNumber, _name));
      nameToFavoriteNumber[_name] = _favoriteNumber;
    }

}

// 21-02-2025


// Remix Simple Storage Deplot to

// SPDX-License-Identifier: MIT
// New simple smart contract added on May 3, 2025

contract SimpleAuction {
    // Data variables
    address public beneficiary;
    uint public auctionEndTime;
    
    // Current state of the auction
    address public highestBidder;
    uint public highestBid;
    
    // Allowed withdrawals of previous bids
    mapping(address => uint) public pendingReturns;
    
    // Set to true at the end, disallows any change
    bool public ended;
    
    // Events to notify clients
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    
    // Constructor creates auction with given parameters
    constructor(uint _biddingTime, address _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }
    
    // Bid on the auction with the value sent
    // The value will only be refunded if the auction is not won
    function bid() public payable {
        // Check if auction still open
        require(block.timestamp <= auctionEndTime, "Auction already ended");
        
        // Check if bid is higher
        require(msg.value > highestBid, "There already is a higher bid");
        
        if (highestBid != 0) {
            // Return the previous highest bid to the bidder
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }
    
    // Withdraw a previously refunded bid
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // Set pending return to zero to prevent double withdrawal attempts
            pendingReturns[msg.sender] = 0;
            
            if (!payable(msg.sender).send(amount)) {
                // If withdrawal fails, restore the amount
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
    
    // End the auction and send the highest bid to the beneficiary
    function auctionEnd() public {
        // Check auction has already ended
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!ended, "Auction end has already been called");
        
        // Mark auction as ended
        ended = true;
        
        // Send highest bid to beneficiary
        emit AuctionEnded(highestBidder, highestBid);
        
        // Transfer funds to beneficiary
        payable(beneficiary).transfer(highestBid);
    }
}


