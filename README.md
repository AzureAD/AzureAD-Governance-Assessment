# Azure AD Governance Assessment

**Please refer to the [Wiki](https://github.com/AzureAD/AzureAD-Governance-Assessment/wiki/1.-Installation) for detail on how to [install](https://github.com/AzureAD/AzureAD-Governance-Assessment/wiki/1.-Installation) and use the scripts.**

The Azure AD Governance Assessment module runs an analysis of guest users and their permissions in a tenant. 

The assessment will return following reports:

- Tenant level settings
- List of guest users, sign-in details, last sign-in, etc.
- List of service principals
- List of guest users in Microsoft Teams
- Conditional Access policies excluding guest users
- Application role assignments
- External guest user sign-in and audit logs
- Directory roles assigned to guest users

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
