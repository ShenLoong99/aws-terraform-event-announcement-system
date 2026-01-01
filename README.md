<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Unlicense License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<div>
   <h1>✅ Full-Stack BucketList Tracker</h1>
   <p align="center"> <img src="assets/aws-amplify.jpg" alt="aws-amplify" width="800"/><br>
      <strong>A Serverless Adventure Logging Application</strong> 
   </p>
   <p> 
    The <strong>BucketList Tracker</strong> is a full-stack, serverless application that allows users to authenticate, manage their personal travel goals, and upload "inspiration photos" for each adventure. Built with React and powered by an automated AWS backend provisioned via Terraform. <br /> 
    <a href="#about-the-project"><strong>Explore the docs »</strong></a>
  </p>
</div>
<details>
   <summary>Table of Contents</summary>
   <ol>
      <li><a href="#about-the-project">About The Project</a></li>
      <li><a href="#built-with">Built With</a></li>
      <li><a href="#use-cases">Use Cases</a></li>
      <li><a href="#architecture">Architecture</a></li>
      <li><a href="#file-structure">File Structure</a></li>
      <li><a href="#getting-started">Getting Started</a></li>
      <li><a href="#usage">Usage & Testing</a></li>
      <li><a href="#roadmap">Roadmap</a></li>
      <li><a href="#challenges-faced">Challenges</a></li>
      <li><a href="#cost-optimization">Cost Optimization</a></li>
   </ol>
</details>

<h2 id="about-the-project">About The Project</h2>
<p> This project demonstrates a robust <strong>Infrastructure as Code (IaC)</strong> pipeline for a modern web application. It solves the common challenge of 1-click deployments by using Terraform Cloud to manage AWS resources and a custom <strong>Webhook Trigger</strong> system to ensure the frontend build always has the latest infrastructure IDs (Cognito Pools, S3 Buckets, AppSync URLs) without manual configuration. </p>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="built-with">Built With</h2>
<p> 
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/react/react-original.svg" alt="react" width="45" height="45" style="margin: 10px;"/> 
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/terraform/terraform-original.svg" alt="terraform" width="45" height="45" style="margin: 10px;"/> 
  <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Architecture-Service-Icons_01312022/Arch_Security-Identity-Compliance/48/Arch_Amazon-Cognito_48.svg" alt="cognito" width="45" height="45" style="margin: 10px;"/> 
  <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Architecture-Service-Icons_01312022/Arch_Front-End-Web-Mobile/48/Arch_AWS-Amplify_48.svg" alt="amplify" width="45" height="45" style="margin: 10px;"/> 
  <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Architecture-Service-Icons_01312022/Arch_App-Integration/Arch_48/Arch_AWS-AppSync_48.svg" alt="appsync" width="45" height="45" style="margin: 10px;"/> 
  <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Resource-Icons_01312022/Res_Storage/Res_48_Light/Res_Amazon-Simple-Storage-Service_S3-Standard_48_Light.svg" alt="s3" width="45" height="45" style="margin: 10px;"/> 
  <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Architecture-Service-Icons_01312022/Arch_Database/48/Arch_Amazon-DynamoDB_48.svg" alt="dynamodb" width="45" height="45" style="margin: 10px;"/> </p>
</p>
<ul>
   <li><strong>React (Vite):</strong> Fast, modern UI with Tailwind CSS for styling.</li>
   <li><strong>Terraform:</strong> Full IaC management of Cognito, S3, AppSync, and Amplify Hosting.</li>
   <li><strong>AWS Cognito:</strong> Multi-layer auth using User Pools (Identity) and Identity Pools (IAM Credentials).</li>
   <li><strong>AWS AppSync (GraphQL):</strong> Managed API for real-time bucket list data storage.</li>
   <li><strong>Amazon S3:</strong> Secure storage for bucket list adventure images.</li>
   <li><strong>Amazon DynamoDB:</strong> NoSQL database used to store bucket list items and user-specific metadata.</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="use-cases">Use Cases</h2>
<ul>
   <li><strong>Travel Planning:</strong> Log future travel destinations with visual references.</li>
   <li><strong>Serverless Showcase:</strong> A template for production-grade React + AWS + Terraform deployments.</li>
   <li><strong>Secure Media Handling:</strong> Demonstrates Cognito Identity Pool "AssumeRole" logic for client-side S3 uploads.</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="architecture">Architecture</h2>
<img src="assets/bucket-list-tracker.jpg" alt="archicture-diagram" width="800">
<p> The architecture is built on a <strong>Deterministic Deployment</strong> model: </p>
<ol>
   <li><strong>State Management:</strong> Terraform Cloud manages the AWS backend.</li>
   <li><strong>The Handshake:</strong> Cognito Identity Pools are linked to IAM Roles via <code>roles_attachment</code> to provide scoped credentials for S3.</li>
   <li><strong>CI/CD Bridge:</strong> Amplify "Auto-build" is disabled. Terraform triggers a deployment via an <strong>Amplify Webhook</strong> only after successfully updating Environment Variables.</li>
   <li><strong>Storage:</strong> S3 Bucket Policies and CORS allow authenticated browser uploads via AWS Amplify SDK.</li>
</ol>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="file-structure">File Structure</h2>
<pre>
AWS-TERRAFORM-BUCKETLIST/
├── .terraform/                     # Local Terraform environment data
├── assets/                         # Documentation images/media for README
├── frontend/                       # React + Vite application source code
│   ├── src/
│   │   ├── App.jsx                 # Main Logic + Amplify Configuration
│   │   └── main.jsx                # Entry point
│   ├── public/                     # Static assets (logo, etc.)
│   ├── .env                        # Local development variables
│   ├── package.json                # React Dependencies (aws-amplify, lucide-react)
│   └── vite.config.js              # Vite configuration
├── modules/                        # Infrastructure as Code modules
│   ├── api/                        # AppSync GraphQL API configuration
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── auth/                       # Cognito User Pool & Identity Pool
│   │   ├── main.tf                 # Identity Pool & Role Handshake logic
│   │   ├── outputs.tf
│   │    variables.tf
│   ├── database/                   # DynamoDB or other data storage
│   │   ├── main.tf                 
│   │   └── outputs.tf
│   ├── hosting/                    # Amplify App, Branch, & Webhook Trigger
│   │   ├── main.tf                 # Webhook & build trigger logic
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── storage/                    # S3 Bucket for image uploads
│       ├── main.tf                 # Bucket policy & CORS configuration
│       ├── outputs.tf
│       └── variables.tf
├── .gitignore                      # Excludes secrets and temporary files
├── .terraform.lock.hcl             # Terraform provider lock file
├── amplify.yml                     # Amplify build specification
├── main.tf                         # Root module (Instantiates all modules)
├── outputs.tf                      # Root level outputs (e.g., App URL)
├── README.md                       # Project documentation
├── schema.graphql                  # AppSync GraphQL schema definition
├── terraform.tf                    # Terraform & Provider configuration
├── terraform.tfstate               # Local state file (if not using Cloud)
├── terraform.tfstate.backup        # State backup file
└── variables.tf                    # Root level input variables
</pre>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="getting-started">Getting Started</h2>
<h3>Prerequisites</h3>
<ul>
   <li><strong>AWS Account:</strong> IAM credentials with Administrator access.</li>
   <li><strong>Terraform Cloud Account:</strong> A free account with a workspace configured for "API-driven" or "Version Control" workflow.</li>
   <li><strong>GitHub Personal Access Token (PAT):</strong> Required for Terraform to link the AWS Amplify App to your source code.</li>
   <li><strong>Set your AWS Region:</strong> Set to whatever <code>aws_region</code> you want in <code>variables.tf</code>.</li>
</ul>
<h3>GitHub Token Setup</h3>
<p>To allow Terraform to provision the Amplify project, you must create a token that grants AWS access to your repository:</p>
<ol>
   <li>Go to <strong>GitHub Settings > Developer Settings > Personal Access Tokens (Tokens classic)</strong>.</li>
   <li>Generate a new token with <code>repo</code> and <code>admin:repo_hook</code> scopes</li>
   <li><strong>Important:</strong> Copy this token immediately. You will provide this to Terraform Cloud as a variable named <code>github_token</code>.</li>
</ol>

<h3>Terraform State Management</h3>
<p>Select one:</p>
<ol>
   <li>Terraform Cloud</li>
   <li>Terraform Local CLI</li>
</ol>

<h4>Terraform Cloud Configuration</h4>
<p>If you choose Terraform Cloud, please follow the steps below:</p>
<ol>
   <li>Create a new <strong>Workspace</strong> in Terraform Cloud.</li>
   <li>In the Variables tab, add the following <strong>Terraform Variables:</strong>
   <ul>
    <li><strong>github_token</strong>: (The PAT created in Step 1, marked as Sensitive).</li>
   </ul>
   </li>
   <li>
    Add the following <strong>Environment Variables</strong> (AWS Credentials):
    <ul>
      <li><code>AWS_ACCESS_KEY_ID</code></li>
      <li><code>AWS_SECRET_ACCESS_KEY</code></li>
   </ul>
   </li>
</ol>

<h4>Terraform Local CLI Configuration</h4>
<p>If you choose Terraform Local CLI, please follow the steps below:</p>
<ol>
   <li>
      Comment the <code>backend</code> block in <code>terraform.tf</code>:
      <pre># backend "remote" {
#   hostname     = "app.terraform.io"
#   organization = "my-terraform-aws-projects-2025"
#   workspaces {
#     name = "bucket-list-tracker"
#   }
# }</pre>
   </li>
   <li>
    Add the following <strong>Environment Variables</strong> (AWS Credentials):
    <pre>git bash command:
export AWS_ACCESS_KEY_ID=&lt;your-aws-access-key-id&gt;
export AWS_SECRET_ACCESS_KEY=&lt;your-aws-secret-access-key&gt;
export TF_VAR_github_token=&lt;your-github-token&gt;</pre>
   </li>
</ol>

<h3>Installation & Deployment</h3>
<ol>
   <li>Clone the repository.</li>
   <li><strong>Terraform Cloud</strong> → <strong>Initialize & Apply:</strong> Push your code to GitHub. Terraform Cloud will automatically detect the change, run a <code>plan</code>, and wait for your approval.</li>
   <li><strong>Terraform CLI</strong> → <strong>Initialize & Apply:</strong> Run <code>terraform init</code> → <code>terraform plan</code> → <code>terraform apply</code>, and wait for your approval.</li>
   <li>
      <strong>The Webhook Handshake:</strong> Once you approve the plan, Terraform will create the backend. It will then automatically trigger the <strong>AWS Amplify Webhook</strong> to start the frontend build.<br>
      <img src="assets/deployment-log.png" alt="deployment-log" width="400" />
   </li>
   <li>
      <strong>Pro-Tip:</strong>  Local Development To test changes without deploying to production, create a <code>.env.local</code> file in the <code>frontend/</code> directory. Populate it with the outputs from your Terraform apply (User Pool IDs, S3 Bucket name, etc.) to link your local dev server to your live AWS resources
   </li>
</ol>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="usage">Usage & Testing</h2>
<ol>
  <li>
    <strong>View</strong> the website.<br>
    <img src="assets/login-page.png" alt="login-page" width="400">
   </li>
   <li>
    <strong>Authentication:</strong> Sign up using the Cognito Authenticator UI.<br>
    <img src="assets/register-page.png" alt="register-page" width="300">
    <img src="assets/email-verification-page.png" alt="email-verification-page" width="300">
   </li>
   <li>
    <strong>Login</strong> to the website successfully.<br>
    <img src="assets/buckiet-list-page.png" alt="buckiet-list-page" width="400">
   </li>
   <li><strong>Adding Items:</strong>Enter a title and select an image file.</li>
   <li><strong>Delete Items:</strong>Click delete icon to delete item from bucket list.</li>
   <li>
    <strong>S3 Check:</strong> Verify uploaded images appear in your private S3 bucket in AWS Console under the <code>public/</code> prefix.<br>
    <img src="assets/s3-objects.png" alt="s3-objects" width="400">
   </li>
</ol>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="roadmap">Project Roadmap</h2>
<ul>
   <li>[x] <strong>Core Auth:</strong> Cognito User Pool & Identity Pool Integration</li>
   <li>[x] <strong>Data Layer:</strong> DynamoDB Persistence via AppSync GraphQL API</li>
   <li>[x] <strong>Media:</strong> S3 Storage with IAM Role Handshake</li>
   <li>[x] <strong>DevOps:</strong> Terraform-to-Amplify Webhook Trigger</li>
   <li>[x] <strong>UI/UX:</strong> Add/Delete items with real-time S3 image cleanup</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="challenges-faced">Challenges</h2>
<table>
   <thead>
      <tr>
         <th>Challenge</th>
         <th>Solution</th>
      </tr>
   </thead>
   <tbody>
      <tr>
         <td><strong>Secure GitHub Access</strong></td>
         <td>Used GitHub PATs stored as Sensitive Variables in Terraform Cloud to prevent hardcoding credentials in the <code>hosting module.</code></td>
      </tr>
      <tr>
         <td><strong>Credential Race Condition</strong></td>
         <td>Disabled Amplify auto-build and implemented a <code>null_resource</code> with <code>local-exec</code> to trigger builds only after Infra variables are set.</td>
      </tr>
      <tr>
         <td><strong>Empty IAM Credentials</strong></td>
         <td>Corrected the <code>provider_name</code> in the Identity Pool by stripping <code>https://</code> from the User Pool endpoint.</td>
      </tr>
      <tr>
         <td><strong>Unauthenticated Access</strong></td>
         <td>Implemented a dummy <code>unauthenticated</code> IAM role to satisfy Cognito's requirement for a complete Role Mapping.</td>
      </tr>
      <tr>
         <td><strong>Dangling S3 Objects</strong></td>
         <td>Updated <code>handleDelete</code> logic to parse the S3 URL and call <code>Storage.remove()</code> before deleting the DynamoDB record to prevent storage bloat.</td>
      </tr>
      <tr>
         <td><strong>Missing User Attributes</strong></td>
         <td>Configured <code>read_attributes</code> in Terraform and utilized <code>fetchUserAttributes</code> in React to display the <code>preferred_username</code> instead of the Cognito UUID.</td>
      </tr>
      <tr>
         <td><strong>Regional Mismatch</strong></td>
         <td>Standardized <code>VITE_REGION</code> across <code>main.jsx</code> and <code>App.jsx</code> to ensure S3 and Cognito clients targeted the correct Singapore (<code>ap-southeast-1</code>) endpoint.</td>
      </tr>
   </tbody>
</table>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

<h2 id="cost-optimization">Cost Optimization</h2>
<ul>
   <li><strong>Serverless Pricing:</strong> No costs incurred while the app is idle (Pay-as-you-go).</li>
   <li><strong>Free Tier:</strong> Stays within limits for the first 50,000 monthly active users (Cognito).</li>
   <li><strong>Amplify Webhooks:</strong> Prevents multiple failed builds by ensuring the environment is ready before building.</li>
   <li><strong>Storage Efficiency:</strong> Explicitly deletes media from S3 when a list item is removed, ensuring you don't pay for "ghost" images that are no longer referenced in the database.</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

[contributors-shield]: https://img.shields.io/github/contributors/ShenLoong99/aws-terraform-bucket-list-tracker.svg?style=for-the-badge
[contributors-url]: https://github.com/ShenLoong99/aws-terraform-bucket-list-tracker/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ShenLoong99/aws-terraform-bucket-list-tracker.svg?style=for-the-badge
[forks-url]: https://github.com/ShenLoong99/aws-terraform-bucket-list-tracker/network/members
[stars-shield]: https://img.shields.io/github/stars/ShenLoong99/aws-terraform-bucket-list-tracker.svg?style=for-the-badge
[stars-url]: https://github.com/ShenLoong99/aws-terraform-bucket-list-tracker/stargazers
[issues-shield]: https://img.shields.io/github/issues/ShenLoong99/aws-terraform-bucket-list-tracker.svg?style=for-the-badge
[issues-url]: https://github.com/ShenLoong99/aws-terraform-bucket-list-tracker/issues
[license-shield]: https://img.shields.io/github/license/ShenLoong99/aws-terraform-bucket-list-tracker.svg?style=for-the-badge
[license-url]: https://github.com/ShenLoong99/aws-terraform-bucket-list-tracker/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/si-kai-tan
