// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonorRegistry {
    string[] organs = [
        "heart",
        "liver",
        "kidneys",
        "intestines",
        "lungs",
        "pancreas"
    ];

    address contractCreator; // address of the contract creator

    struct Hospitals {
        bytes32 id;
        string email;
        bytes32 passwordHash; // hashed password of the donor
        bool registered;
        bool licenseDocUploaded;
        string DocumentTxId;
        string name;
    }

    struct Donor {
        bytes32 id; // unique id of the donor
        string email; // email of the donor
        bytes32 passwordHash; // hashed password of the donor
        bool registered;
        bool authorised;
        bool ehrUploaded;
        bytes32 hospital;
    }

    struct Recipient {
        bytes32 id; // unique id of the donor
        string email; // email of the donor
        bytes32 passwordHash; // hashed password of the donor
        bool registered;
        bool authorised;
        bool ehrUploaded;
        bool matchFound;
        bytes32 hospital;
    }

    struct DonorDetail {
        string id;
        string addr;
        string email;
        string contactNumber;
        string ehrTxId;
        string[] organsList;
        string[] matchOrgans;
    }

    struct RecipientDetail {
        string id;
        string addr;
        string email;
        string contactNumber;
        string ehrTxId;
        string organ;
    }

    mapping(bytes32 => Hospitals) public Hospital;

    mapping(string => bytes32) public hospitalId;

    mapping(bytes32 => string) public hopitalName;

    bytes32[] public hospitalIds;

    string[] public hospitalNames;

    mapping(bytes32 => bytes32[]) public hospitalDonors;

    mapping(bytes32 => bytes32[]) public hospitalRecipients;

    mapping(bytes32 => string[]) public donorTraceBlocks;

    mapping(bytes32 => Donor) public donors; // mapping to store all donors

    mapping(bytes32 => DonorDetail) public DonorDetails;

    bytes32[] public donorIds;

    mapping(bytes32 => string[]) public recipientTraceBlocks;

    mapping(bytes32 => Recipient) public recipients; // mapping to store all donors

    mapping(bytes32 => RecipientDetail) public recipientDetails;

    bytes32[] public recipientIds;

    mapping(bytes32 => bytes32) public recipientMatches;

    mapping(bytes32 => bytes32) public donorMatches;

    bytes32[] public recipientmatches;

    bytes32[] public donormatches;

    constructor() {
        contractCreator = msg.sender;
    }

    //Hospital
    function registerHospital(
        string memory email,
        string memory password,
        string memory name
    ) public {
        bytes32 id = keccak256(abi.encodePacked(email)); // generating unique id using keccak256
        require(!Hospital[id].registered, "email already exists");
        Hospital[id] = Hospitals(
            id,
            email,
            keccak256(abi.encodePacked(password)),
            true,
            false,
            "-1",
            "name"
        );
        hospitalIds.push(id);
        hospitalId[name] = id;
        hopitalName[id] = name;
        hospitalNames.push(name);
    }

    function HospitalSignIn(string memory email, string memory password)
        public
        view
        returns (bytes32)
    {
        bytes32 id = keccak256(abi.encodePacked(email));
        require(
            Hospital[id].passwordHash == keccak256(abi.encodePacked(password)),
            "incorrect email or password"
        );
        return id;
    }

    function getHospitalName(bytes32 id) public view returns(string memory) {
        return hopitalName[id];
    }

    function HospitalEHRAdd(string memory Id, bytes32 id) public {
        require(donors[id].registered, "donor not registered");
        Hospital[id].DocumentTxId = Id;
        Hospital[id].licenseDocUploaded = true;
    }

    function getHospitalNames() public view returns (string[] memory) {
        return hospitalNames;
    }

    function getDonorMatches() public view returns (bytes32[] memory) {
        return donormatches;
    }

    function getRecipientMatchs() public view returns (bytes32[] memory) {
        return recipientmatches;
    }

    function getHospitalDonors(bytes32 id) public view returns (bytes32[] memory) {
        return hospitalDonors[id];
    }

    function getHospitalRecipients(bytes32 id) public view returns (bytes32[] memory) {
        return hospitalRecipients[id];
    }

    //For DONOR

    function registerDonor(
        string memory email,
        string memory password,
        string memory Hname
    ) public {
        bytes32 id = keccak256(abi.encodePacked(email)); // generating unique id using keccak256
        require(!donors[id].registered, "email already exists");
        require(
            keccak256(abi.encodePacked(hospitalId[Hname])) !=
                keccak256(
                    abi.encodePacked(
                        bytes32(
                            0x0000000000000000000000000000000000000000000000000000000000000000
                        )
                    )
                ),
            "Hospital doesn't exists"
        );
        donors[id] = Donor(
            id,
            email,
            keccak256(abi.encodePacked(password)),
            true,
            false,
            false,
            hospitalId[Hname]
        );
        donorIds.push(id);
        hospitalDonors[hospitalId[Hname]].push(id);
    }

    function authoriseDonor(bytes32 id, bytes32 hId) public {
        require(
            donors[id].hospital == hId,
            "donor not belongs to this hospital"
        );
        require(donors[id].registered, "donor not registered");
        // require(donors[id].ehrUploaded, "please upload your EHR");
        donors[id].authorised = true;
    }

    function unauthoriseDonor(bytes32 id) public {
        // require(
        //     donors[id].hospital == hId,
        //     "donor not belongs to this hospital"
        // );
        // require(donors[id].registered, "donor not registered");
        donors[id].authorised = false;
        // rollBackMatches(id);
    }

    function rollBackMatches(bytes32 donorId) public {
        require(
            DonorDetails[donorId].matchOrgans.length > 0,
            "organs matchs not found"
        );
        for (uint256 i = 0; i < DonorDetails[donorId].matchOrgans.length; i++) {
            DonorDetails[donorId].organsList.push(
                DonorDetails[donorId].matchOrgans[i]
            );
        }
        for (uint256 i = 0; i < DonorDetails[donorId].matchOrgans.length; i++) {
            DonorDetails[donorId].matchOrgans.pop();
        }
        recipients[donorMatches[donorId]].matchFound = false;
    }

    function getDonorsCount() public view returns (uint256) {
        return donorIds.length;
    }

    function donorSignIn(string memory email, string memory password)
        public
        view
        returns (bytes32)
    {
        bytes32 id = keccak256(abi.encodePacked(email));
        require(
            donors[id].passwordHash == keccak256(abi.encodePacked(password)),
            "incorrect email or password"
        );
        return id;
    }

    function editDonorDetails(
        bytes32 id,
        string memory addr,
        string memory contactNumber,
        string[] memory list
    ) public {
        require(donors[id].registered, "donor not registered");
        // require(donors[id].authorised, "not athorised donor");
        // require(donors[id].ehrUploaded, "please upload your EHR");
        DonorDetails[id].email = donors[id].email;
        DonorDetails[id].addr = addr;
        DonorDetails[id].contactNumber = contactNumber;
        DonorDetails[id].organsList = list;
    }

    function donorEHRAdd(string memory ehrId, bytes32 id) public {
        require(donors[id].registered, "donor not registered");
        DonorDetails[id].ehrTxId = ehrId;
        donors[id].ehrUploaded = true;
    }

    function getDonorOrganList(bytes32 id)
        public
        view
        returns (string[] memory)
    {
        // require(donors[id].authorised, "not athorised donor");
        // require(donors[id].ehrUploaded, "please upload your EHR");
        return DonorDetails[id].organsList;
    }

    function getMatchedOrganList(bytes32 id)
        public
        view
        returns (string[] memory)
    {
        // require(donors[id].authorised, "not athorised donor");
        // require(donors[id].ehrUploaded, "please upload your EHR");
        return DonorDetails[id].matchOrgans;
    }

    //registartion
    //editdetails
    //authorised
    //unauthorised
    //donor add EHR
    function updateDonorTrace(bytes32 id, string memory txHash) public {
        donorTraceBlocks[id].push(txHash);
    }

    function getDonorTrace(bytes32 id) public view returns (string[] memory) {
        return donorTraceBlocks[id];
    }

    // FOR RECIPIENT

    function registerRecipient(
        string memory email,
        string memory password,
        string memory Hname
    ) public {
        bytes32 id = keccak256(abi.encodePacked(email)); // generating unique id using keccak256
        require(!recipients[id].registered, "email already exists");
        require(
            keccak256(abi.encodePacked(hospitalId[Hname])) !=
                keccak256(
                    abi.encodePacked(
                        bytes32(
                            0x0000000000000000000000000000000000000000000000000000000000000000
                        )
                    )
                ),
            "Hospital doesn't exists"
        );
        recipients[id] = Recipient(
            id,
            email,
            keccak256(abi.encodePacked(password)),
            true,
            false,
            false,
            false,
            hospitalId[Hname]
        );
        recipientIds.push(id);
        hospitalRecipients[hospitalId[Hname]].push(id);
    }

    function authorisedRecipient(bytes32 id, bytes32 hId) public {
        require(
            recipients[id].hospital == hId,
            "donor not belongs to this hospital"
        );
        require(recipients[id].registered, "recipient not registered");
        // require(recipients[id].ehrUploaded, "please upload your EHR");
        recipients[id].authorised = true;
    }

    function unauthoriseRecipient(bytes32 id) public {
        // require(
        //     recipients[id].hospital == hId,
        //     "donor not belongs to this hospital"
        // );
        // require(recipients[id].registered, "recipient not registered");
        recipients[id].authorised = false;
        // rollBackMatches(recipientMatches[id]);
    }

    function recipientSignIn(string memory email, string memory password)
        public
        view
        returns (bytes32)
    {
        bytes32 id = keccak256(abi.encodePacked(email));
        require(
            recipients[id].passwordHash ==
                keccak256(abi.encodePacked(password)),
            "incorrect email or password"
        );
        return id;
    }

    function editRecipitentDetails(
        bytes32 id,
        string memory addr,
        string memory contactNumber,
        string memory organ
    ) public {
        require(recipients[id].registered, "recipient not registered");
        // require(recipients[id].authorised, "not athorised recipient");
        // require(recipients[id].ehrUploaded, "please upload your EHR");
        recipientDetails[id].email = recipients[id].email;
        recipientDetails[id].addr = addr;
        recipientDetails[id].contactNumber = contactNumber;
        recipientDetails[id].organ = organ;
    }

    function recipientEHRAdd(string memory ehrId, bytes32 id) public {
        require(recipients[id].registered, "recipient not registered");
        recipientDetails[id].ehrTxId = ehrId;
        recipients[id].ehrUploaded = true;
    }

    //registartion
    //editdetails
    //authorised
    //unauthorised
    //donor add EHR
    function updateRecipientTrace(bytes32 id, string memory txHash) public {
        recipientTraceBlocks[id].push(txHash);
    }

    function getRecipientTrace(bytes32 id)
        public
        view
        returns (string[] memory)
    {
        return recipientTraceBlocks[id];
    }

    function getRecipientsCount() public view returns (uint256) {
        return recipientIds.length;
    }

    function matchOrgans(bytes32 id, string memory organ) public {
        require(!recipients[id].matchFound, "Not already exists");
        bool flag = false;
        for (uint256 i = 0; i < donorIds.length; i++) {
            for (
                uint256 j = 0;
                j < DonorDetails[donorIds[i]].organsList.length;
                j++
            ) {
                require(recipients[id].hospital == donors[donorIds[i]].hospital, "not belongs to same hospital");
                if (
                    keccak256(
                        abi.encodePacked(
                            DonorDetails[donorIds[i]].organsList[j]
                        )
                    ) == keccak256(abi.encodePacked(organ))
                ) {
                    if (donors[donorIds[i]].authorised) {
                        DonorDetails[donorIds[i]].matchOrgans.push(organ);
                        DonorDetails[donorIds[i]].organsList[j] = DonorDetails[
                            donorIds[i]
                        ].organsList[
                                DonorDetails[donorIds[i]].organsList.length - 1
                            ];
                        DonorDetails[donorIds[i]].organsList.pop();
                        recipients[id].matchFound = true;
                        flag = true;
                        recipientMatches[id] = donorIds[i];
                        donormatches.push(donorIds[i]);
                        recipientmatches.push(id);
                        donorMatches[donorIds[i]] = id;
                        break;
                    }
                }
            }
            if (flag) {
                break;
            }
        }
    }

        function matchOthersOrgans(bytes32 id, string memory organ) public {
        require(!recipients[id].matchFound, "Not already exists");
        bool flag = false;
        for (uint256 i = 0; i < donorIds.length; i++) {
            for (
                uint256 j = 0;
                j < DonorDetails[donorIds[i]].organsList.length;
                j++
            ) {
                if (
                    keccak256(
                        abi.encodePacked(
                            DonorDetails[donorIds[i]].organsList[j]
                        )
                    ) == keccak256(abi.encodePacked(organ))
                ) {
                    if (donors[donorIds[i]].authorised) {
                        DonorDetails[donorIds[i]].matchOrgans.push(organ);
                        DonorDetails[donorIds[i]].organsList[j] = DonorDetails[
                            donorIds[i]
                        ].organsList[
                                DonorDetails[donorIds[i]].organsList.length - 1
                            ];
                        DonorDetails[donorIds[i]].organsList.pop();
                        recipients[id].matchFound = true;
                        flag = true;
                        recipientMatches[id] = donorIds[i];
                        donormatches.push(donorIds[i]);
                        recipientmatches.push(id);
                        donorMatches[donorIds[i]] = id;
                        break;
                    }
                }
            }
            if (flag) {
                break;
            }
        }
    }
}
