// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AttendanceRecordBlockchain {
    address public owner;

    struct Attendance {
        address student;
        uint256 timestamp;
        uint256 dateKey;
    }

    mapping(address => bool) public registered;
    mapping(address => string) public studentNames;
    mapping(address => mapping(uint256 => bool)) public hasAttended;
    mapping(address => Attendance[]) private studentRecords;

    address[] private students;

    event StudentRegistered(address indexed student, string name);
    event AttendanceMarked(
        address indexed student,
        uint256 timestamp,
        uint256 dateKey
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only admin can do this");
        _;
    }

    modifier onlyRegistered() {
        require(registered[msg.sender], "Register first");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerStudent(
        address student,
        string calldata name
    ) external onlyOwner {
        require(student != address(0), "Invalid address");
        require(!registered[student], "Already registered");
        require(bytes(name).length > 0, "Name required");

        registered[student] = true;
        studentNames[student] = name;
        students.push(student);

        emit StudentRegistered(student, name);
    }

    function markAttendance() external onlyRegistered {
        uint256 today = block.timestamp / 1 days;

        require(
            !hasAttended[msg.sender][today],
            "Attendance already marked today"
        );

        hasAttended[msg.sender][today] = true;

        studentRecords[msg.sender].push(
            Attendance({
                student: msg.sender,
                timestamp: block.timestamp,
                dateKey: today
            })
        );

        emit AttendanceMarked(msg.sender, block.timestamp, today);
    }

    function getMyAttendanceCount()
        external
        view
        onlyRegistered
        returns (uint256)
    {
        return studentRecords[msg.sender].length;
    }

    function getMyAttendance(
        uint256 index
    ) external view onlyRegistered returns (
        address student,
        uint256 timestamp,
        uint256 dateKey
    ) {
        require(
            index < studentRecords[msg.sender].length,
            "Invalid record index"
        );

        Attendance storage record = studentRecords[msg.sender][index];

        return (
            record.student,
            record.timestamp,
            record.dateKey
        );
    }

    function getStudentCount()
        external
        view
        onlyOwner
        returns (uint256)
    {
        return students.length;
    }

    function getStudent(
        uint256 index
    ) external view onlyOwner returns (
        address student,
        string memory name
    ) {
        require(index < students.length, "Invalid student index");

        address studentAddress = students[index];

        return (
            studentAddress,
            studentNames[studentAddress]
        );
    }

    function checkAttendance(
        address student,
        uint256 dateKey
    ) external view returns (bool) {
        return hasAttended[student][dateKey];
    }
}
