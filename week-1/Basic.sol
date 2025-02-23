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
// zkSync Testnet with zkSync  Plugin
// zkSync Contract Interactions

// zkSync Testnet with zkSync Plugin (Setup & Deployment)
// zkSync is a Layer 2 solution using zk-rollups, which reduces gas 
// fees and increases scalability. The zkSync Hardhat plugin helps you compile,
//  deploy, and interact with zkSync-compatible smart contracts.



// The EVM  Ethereum Virtual Machine
// Ethereum, Polygon, Arbitrum, Optimism, Zksync



// The Ethereum Virtual Machine (EVM) is the core component of the Ethereum blockchain. It acts as a decentralized computer that allows anyone to 
// run code (smart contracts) on the Ethereum network. The EVM ensures that the same code produces the same results across all nodes, maintaining
//  consensus throughout the network.

//  Why EVM is Important
// Security: The EVM isolates code execution, preventing harmful operations from affecting the network.
// Interoperability: Since all Ethereum-compatible chains use EVM, dApps can work across multiple networks (like Binance Smart Chain, Polygon).
// Consensus: The EVM ensures all nodes agree on the state of the blockchain after transactions are processed.


//  How the EVM Works


// 1 Smart Contracts:

// Developers write smart contracts in Solidity.
// These contracts are compiled into EVM bytecode and deployed on the Ethereum blockchain.

// 2 Transactions:

// Users interact with smart contracts by sending transactions.
// Each transaction that triggers contract execution is processed by the EVM.


// 3 Gas Mechanism:

// Every computation requires gas, which users pay in Ether (ETH).
// Gas prevents spam and ensures efficient use of computational resources.
