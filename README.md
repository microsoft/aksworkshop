# aksworkshop.io

This is the repository for the Azure Kubernetes Service (AKS) Workshop website. For the full workshop experience, go to <https://aksworkshop.io>

Feel free to open Issues with requests for new topics or challenges.


## Technology

- The website is statically built using Jekyll and you’ll find the different pages inside the `_entries` folder
- You can preview your edits locally if you run `make build-run` inside the repository root
- The build pipeline builds Docker images of the site and hosts it on a private repository on Azure Container Registry (`msworkshops.azurecr.io`)
- The `master` branch gets deployed to the production slot [aksworkshop.io](https://aksworkshop.io)
- The `staging` branch gets deployed to the staging slot [staging.aksworkshop.io](https://staging.aksworkshop.io)
- The `devsecops` branch gets deployed to the devsecops slot [devsecops.aksworkshop.io](https://devsecops.aksworkshop.io)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

 Since the workshop is running live, please fork and branch off `staging`, then submit a Pull Request against `staging`.
 After your PR is approved and staging is tested it will be merged to master on the next weekend. 
**If it's urgent**, then follow with a PR against master. 
In both cases it's desirable that every PR has an issue linking to it. 
 
 If you want your name to show up in the [contributors](https://aksworkshop.io/#contributors), please add your GitHub username to [`_entries/99 Contributors.md`](_entries/99%20Contributors.md) in alphabetical order.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Legal Notices

Microsoft and any contributors grant you a license to the Microsoft documentation and other content
in this repository under the [Creative Commons Attribution 4.0 International Public License](https://creativecommons.org/licenses/by/4.0/legalcode),
see the [LICENSE](LICENSE) file, and grant you a license to any code in the repository under the [MIT License](https://opensource.org/licenses/MIT), see the
[LICENSE-CODE](LICENSE-CODE) file.

Microsoft, Windows, Microsoft Azure and/or other Microsoft products and services referenced in the documentation
may be either trademarks or registered trademarks of Microsoft in the United States and/or other countries.
The licenses for this project do not grant you rights to use any Microsoft names, logos, or trademarks.
Microsoft's general trademark guidelines can be found at http://go.microsoft.com/fwlink/?LinkID=254653.

Privacy information can be found at https://privacy.microsoft.com/en-us/

Microsoft and any contributors reserve all other rights, whether under their respective copyrights, patents,
or trademarks, whether by implication, estoppel or otherwise.
