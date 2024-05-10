# school-management-sui-move

The School Management Smart Contract is a decentralized application (DApp) built on the SUI (Move) programming language for the Move blockchain. It provides a comprehensive solution for managing various aspects of a school, including student enrollment, attendance tracking, fee management, and more.

Features:

Student Enrollment: Allows administrators to register new students, storing their personal information such as name, age, gender, and contact details.

Attendance Tracking: Enables teachers to mark attendance for students, keeping track of their attendance records securely on the blockchain.

Fee Management: Facilitates the collection of fees from students and tracks their payment status. It generates detailed bills for students and records payment transactions.

Academic Records: Stores academic records such as grades, exam results, and class assignments securely on the blockchain.

User Permissions: Implements role-based access control, allowing administrators, teachers, and students to access specific functionalities based on their roles.

Testing Environment: Provides a testing environment with predefined scenarios for testing the functionality of the smart contract.
Usage:


The School Management Smart Contract can be deployed on a blockchain network supporting the Move programming language, such as the SUI blockchain. Schools and educational institutions can leverage this smart contract to streamline administrative processes, enhance transparency, and improve data security.

**How to Contribute:**

Contributions to the project are welcome! You can contribute by testing the smart contract, reporting bugs, or suggesting improvements. Fork the repository, make your changes, and submit a pull request.

 # Installation
Follow these steps to deploy and use the Hospital Management System:

Move Compiler Installation: Ensure you have the Move compiler installed. Refer to the Sui documentation for installation instructions.

Compile the Smart Contract: Switch the dependencies in the Sui configuration to match your chosen framework (framework/devnet or framework/testnet), then build the contract.

sui move build

Deployment: Deploy the compiled smart contract to your chosen blockchain platform using the Sui command-line interface.

sui client publish --gas-budget 100000000 --json

# SUI ENV SETUP
- Ensure your development environment is set up properly to avoid errors.
- Logs and debug reports can provide specific information to troubleshoot issues during deployment or execution.
- Consider implementing a testing suite to validate smart contract functions before deployment.
