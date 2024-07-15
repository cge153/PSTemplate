# PSTemplate

This is a PowerShell module template project.

## Description

## Module Directory Structure

```text
PSTemplate/
├── build/
│   └── build.ps1
├── src/
│   ├── Classes/
│   │   └── MyClass.ps1
│   ├── Config/
│   │   ├── config.json
│   │   └── properties.ps1
│   ├── Private/
│   │   ├── Get-Private.ps1
│   │   └── Set-Private.ps1
│   ├── Public/
│   │   ├── Get-ApiData.ps1
│   │   └── Set-Public.ps1
│   ├── PSTemplate.psd1
│   └── PSTemplate.psm1
├── tests/
│   ├── Private/
│   │   ├── Get-Private.Tests.ps1
│   │   └── Set-Private.Tests.ps1
│   └── Public/
│       ├── Get-Public.Tests.ps1
│       └── Set-Public.Tests.ps1
├── .gitignore
├── CHANGELOG.md
└── README.md
```

## Temp

### Resources

- <https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/>
- <https://benheater.com/creating-a-powershell-module/>
- Module Structure: <https://tomasdeceuninck.github.io/2018/04/17/PowerShellModuleStructure.html>
