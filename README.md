You need to execute this in Powershell for the tool to work:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser


# Midnight Scavenger Consolidation Tool (PowerShell GUI)

A Windows PowerShell GUI tool for consolidating Scavenged NIGHT allocations from multiple donor wallets into a single recipient wallet using the official Midnight **donate_to** API endpoint.

This tool provides:
- A graphical interface for entering donor, recipient, and signature data
- Automatic storage of your recipient address
- One-click copy of the signing message required by Eternl or other wallets
- Full JSON response output from the Midnight API
- Detailed logging of all operations
- Clean and user-friendly workflow

> **Important:**  
> This tool does **not** collect, send, or store any private keys or seed phrases.  
> You only paste the *signature* created in your own wallet.

---

## ⚠️ Disclaimer

This tool is provided **as-is** with **no warranty of any kind**.  
You use it **at your own risk**.

- Midnight’s API, backend, and mechanics may change at any time  
- The tool may cease to work without warning  
- Always test with a small or non-critical donor address first  
- Double-check all addresses before submitting a consolidation  
- The author is **not responsible** for lost funds, incorrect transactions, or mis-use

---

## 🤖 AI-Generated Notice

Portions of the code and documentation were generated, assisted, or refined with the help of **AI tools (ChatGPT)**.  
All code has been manually reviewed, but you should still inspect it yourself before use.

---

## 📦 Requirements

- **Windows 10 or Windows 11**
- **PowerShell 5+** (included with Windows)
- Internet access (for API calls)
- A wallet capable of:
  - Displaying your donor addresses  
  - Signing the required message (e.g., Eternl Wallet)

---

## 🚀 Installation

1. Download or clone this repository.
2. Make sure the PowerShell script is unblocked:
   ```powershell
   Unblock-File .\helper.ps1
