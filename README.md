# Duplicate Weapon Series Tracker

This Lua script is designed for Fivem servers to track and manage duplicate weapon series in player inventories. It effectively identifies duplicates, organizes data, and saves this information in JSON format for easy review and auditing.

## Features

- **Duplicate Detection**: Identifies duplicate weapons based on their series.
- **Data Export**: Generates JSON files with summaries of duplicate weapons and player details.
- **Custom Sorting**: Sorts players by the number of duplicate weapons.
- **Efficient Processing**: Handles large player datasets in batches.

## Getting Started

### Prerequisites

- The script is intended for a Fivem server.
- Requires `oxmysql` for database interactions.
- Made For `qb-core` 

### Usage

Run the command `checkdupeweapons` in the server console to start the duplicate weapon series check.

> **Note**: This command is only executable from the server console.


## Output

- **`duplicateWeapons_YYYY-MM-DD.json`**: Detailed information on each duplicate weapon series.
- **`duplicateSummary_YYYY-MM-DD.json`**: Summary of players with counts of duplicate weapons.

## Limitations

- The script relies on specific inventory data structures in the database.
- Server permissions are required for file saving.

## License

This script is provided under the [MIT License](LICENSE).

## Disclaimer

For any questions or issues, feel free to open an issue.

Happy coding!

## Support Me
Grab me a coffee
https://ko-fi.com/irishstevie

## My Discord
https://discord.com/invite/d9AE5WxEDM


