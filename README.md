# Introduction 
This Project utilizes core data saving mechanism as a caching method for data retrieved from the server in a protocol oriented programming way

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
       Take the Device Repo,Backend Repo and Model Protocols and import them to your project
2.	Software dependencies
        None
3.	Latest releases
4.	API references

# Build and Test
    -Start by creating your core data model with your entities & attributes
    once done, 
    create a struct to conform to the Managed protocol ,Device Repo and BackEnd Repo protocols both responsible for the CRUD operations 
    Then from Where ever you want to fetch, cache and save data use an object of that struct to achieve that
    you have the option of checking of new ids from the server and compare them to the ones on your device or you can check the last update but you will need to have that key on the server as well and get the new data afterwards

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)
