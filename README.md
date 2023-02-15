# Azure AD Governance Assessment

> This repo has been populated by an initial template to help get you started. Please
> make sure to update the content to build a great experience for community-building.

As the maintainer of this project, please make a few updates:

- Improving this README.MD file to provide a great experience
- Updating SUPPORT.MD with content about this project's support experience
- Understanding the security reporting process in SECURITY.MD
- Remove this section from the README

## Prerequisites

The module has a dependency on the following three modules: 

- Microsoft.Graph.Authentication
- MicrosoftTeams
- Microsoft.Online.SharePoint.PowerShell

To check whether they are installed, run the following

```powershell
get-module Microsoft.Graph.Authentication -ListAvailable  #repeat for the other modules
```

To install the latest module run the following (as an admin)

```powershell
install-module Microsoft.Graph.Authentication -scope allusers
```


## Run data collection

To do.

## Contents

| File/folder       | Description                                             |
|-------------------|---------------------------------------------------------|
| `build`           | Scripts to package, test, sign, and publish the module. |
| `src`             | Module source code.                                     |
| `.gitignore`      | Define what to ignore at commit time.                   |
| `README.md`       | This README file.                                       |
| `LICENSE`         | The license for the module.                             |
| `CONTRIBUTING.md` | Contributing to the module                              |

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the Microsoft Open Source Code of Conduct. For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.

For more detailed guidance and recommendations for contributing, see the page for contributing.