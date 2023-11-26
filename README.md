# File Integrity Monitoring Tool

## Overview
This PowerShell script provides a File Integrity Monitoring (FIM) tool, allowing users to monitor and verify the integrity of files through hash values. It includes features such as adding files to a baseline, verifying files against the baseline, and creating a new baseline.

## Features
- **Add files to baseline:** Users can add files to the baseline along with their corresponding hash values.
- **Verify files:** The tool checks files against the baseline to identify any changes in their hash values.
- **Create a new baseline:** Users can create a new baseline file.

## Getting Started
1. Clone or download the repository.
2. Run the script in a PowerShell environment.

## Usage
1. **Select baseline file:** Allows users to browse and select an existing baseline file.
2. **Add files for monitoring:** Enables users to add files to the baseline for monitoring.
3. **Check files for changes:** Verifies files against the baseline and notifies if changes are detected.
4. **Create a new baseline file:** Allows users to create a new baseline file.

## Requirements
- PowerShell
- Baseline files must be .csv format.

## License
This project is licensed under the [MIT License](LICENSE).
