<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Unlicense License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<div>
   <h1>📢 Serverless Event Notifier</h1>
   <p align="center"> <img src="assets/aws-sns-logo.png" alt="aws-sns-logo" width="800"/><br>
      <strong>Automated Multi-Channel Event Distribution System</strong> 
   </p>
   <p> The <strong>Serverless Event Notifier</strong> is a full-stack solution enabling organizations to manage event listings and instantly broadcast updates to subscribers. Built with a decoupled microservices architecture, it leverages AWS Lambda, SNS, and S3 to provide a highly scalable, zero-maintenance notification pipeline. <br /> <a href="#about-the-project"><strong>Explore the docs »</strong></a> </p>
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
      <li><a href="#challenges">Challenges</a></li>
      <li><a href="#cost-optimization">Cost Optimization</a></li>
   </ol>
</details>
<h2 id="about-the-project">About The Project</h2>
<p> This project focuses on the <strong>Decoupled Pub/Sub Pattern</strong>. It demonstrates how to handle asynchronous workflows—where a user creates an event in a web dashboard, and the system automatically updates a data store (S3) while simultaneously triggering a notification broadcast (SNS). The entire lifecycle, from the frontend hosting to the backend API Gateway triggers, is provisioned via <strong>Terraform</strong> for 100% reproducible infrastructure. </p>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="built-with">Built With</h2>
<p> 
   <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/javascript/javascript-original.svg" alt="javascript" width="45" height="45" style="margin: 10px;"/> 
   <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/terraform/terraform-original.svg" alt="terraform" width="45" height="45" style="margin: 10px;"/> 
   <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Architecture-Service-Icons_01312022/Arch_App-Integration/Arch_48/Arch_Amazon-Simple-Notification-Service_48.svg" alt="sns" width="45" height="45" style="margin: 10px;"/>
   <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Architecture-Service-Icons_01312022/Arch_Compute/48/Arch_AWS-Lambda_48.svg" alt="lambda" width="45" height="45" style="margin: 10px;"/> 
   <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Resource-Icons_01312022/Res_Storage/Res_48_Light/Res_Amazon-Simple-Storage-Service_S3-Standard_48_Light.svg" alt="s3" width="45" height="45" style="margin: 10px;"/> 
   <img src="https://raw.githubusercontent.com/weibeld/aws-icons-svg/main/q1-2022/Architecture-Service-Icons_01312022/Arch_App-Integration/Arch_48/Arch_ Amazon-API-Gateway_48.svg" alt="api-gateway" width="45" height="45" style="margin: 10px;"/> 
</p>
<ul>
   <li><strong>Vanilla JS + HTML5:</strong> Clean, lightweight frontend using Fetch API for asynchronous backend calls.</li>
   <li><strong>Terraform:</strong> Comprehensive IaC for API Gateway, Lambda, SNS, and S3 Static Web Hosting.</li>
   <li><strong>AWS SNS:</strong> Managed Pub/Sub service for handling email subscriptions and message broadcasting.</li>
   <li><strong>AWS Lambda (Node.js):</strong> Serverless functions for processing subscriptions and updating event metadata.</li>
   <li><strong>Amazon S3:</strong> Dual-purpose storage used for static website hosting and persistent JSON data storage.</li>
   <li><strong>API Gateway:</strong> RESTful entry point with integrated CORS handling and CloudWatch logging.</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="use-cases">Use Cases</h2>
<ul>
   <li><strong>Community Announcements:</strong> Allow members to sign up for email alerts for local town hall or club meetings.</li>
   <li><strong>Internal IT Alerts:</strong> A dashboard for admins to post system maintenance windows and notify all stakeholders instantly.</li>
   <li><strong>Marketing Campaigns:</strong> Quick-deploy landing pages to capture email leads and send instant promotion details.</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="architecture">Architecture</h2>
<p> The system utilizes a <strong>Serverless Event-Driven Architecture</strong>: </p>
<ol>
   <li><strong>Frontend Layer:</strong> Static HTML/JS hosted on S3 sends POST requests to API Gateway.</li>
   <li>
      <strong>Logic Layer:</strong> API Gateway triggers Lambda functions for two specific actions: 
      <ul>
         <li><code>Subscriber Lambda</code>: Registers email addresses to an SNS Topic.</li>
         <li><code>CreateEvent Lambda</code>: Updates <code>events.json</code> in S3 and publishes a message to the SNS Topic.</li>
      </ul>
   </li>
   <li><strong>Notification Layer:</strong> SNS fan-outs the message to all "Confirmed" email subscribers.</li>
   <li><strong>Infrastructure Layer:</strong> Terraform manages the deployment, including API Gateway method responses (CORS) and IAM roles.</li>
</ol>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="file-structure">File Structure</h2>
<pre>EVENT-NOTIFIER-SYSTEM/
├── lambda/                         # Serverless Business Logic
│   ├── subscriber.js               # Handles SNS email subscriptions
│   ├── create_event.js             # Updates S3 and triggers SNS broadcast
│   ├── lambda_subscriber.zip       # Generated by Terraform (archive_file)
│   └── lambda_create.zip           # Generated by Terraform (archive_file)
├── frontend/                       # Static Web Assets
│   ├── index.html.tftpl            # Dynamic template for API URL injection
│   ├── style.css                   # UI styling (includes padding fixes)
│   └── events.json                 # Data store for the event list
├── .terraform/                     # Terraform local working directory
├── .terraform.lock.hcl             # Provider version lock file
├── main.tf                         # Primary Infrastructure configuration
├── variables.tf                    # Region and naming variables
├── outputs.tf                      # S3 URL and API Gateway endpoint outputs
└── terraform.tfstate               # Local state file tracking resources
</pre>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="getting-started">Getting Started</h2>
<h3>Prerequisites</h3>
<ul>
   <li><strong>AWS CLI:</strong> Configured with appropriate IAM permissions.</li>
   <li><strong>Terraform CLI / Terraform Cloud(optional)</strong> for IaC deployment.</li>
   <li><strong>Set your AWS Region:</strong> Set to whatever <code>aws_region</code> you want in <code>variables.tf</code>.</li>
</ul>
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
#   organization = "&lt;your-terraform-organization-name&gt;"
#   workspaces {
#     name = "&lt;your-terraform-workspace-name&gt;"
#   }
# }</pre>
   </li>
   <li>
    Add the following <strong>Environment Variables</strong> (AWS Credentials):
    <pre>git bash command:
export AWS_ACCESS_KEY_ID=&lt;your-aws-access-key-id&gt;
export AWS_SECRET_ACCESS_KEY=&lt;your-aws-secret-access-key&gt;
</ol>
<h3>Installation & Deployment</h3>
<ol>
   <li>
        <strong>Clone the Repository</strong>
    </li>
    <li>
        <strong>Provision Infrastructure:</strong>
        <ul>
          <li>
            <strong>Terraform Cloud</strong> → <strong>Initialize & Apply:</strong> Push your code to GitHub. Terraform Cloud will automatically detect the change, run a <code>plan</code>, and wait for your approval.
          </li>
          <li>
            <strong>Terraform CLI</strong> → <strong>Initialize & Apply:</strong> Run <code>terraform init</code> → <code>terraform plan</code> → <code>terraform apply</code>, and wait for your approval.
          </li>
        </ul>
    </li>
   <li>
      <strong>Note:</strong> Upon the first deployment, S3 may take a moment for DNS propagation. If the initial upload fails, wait 30 seconds and re-run <code>terraform apply</code>.<br>
      <img src="assets/event-announcement-system-page.png" alt="event-announcement-system-page" width="800"/>
   </li>
</ol>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="usage">Usage & Testing</h2>
<ol>
   <li>
      <strong>Subscription:</strong> Enter your email in the "Subscribe" box. Check your inbox for an AWS Confirmation email and click the <strong>Confirm</strong> link.<br>
      <img src="assets/subscribed-msg.png" alt="subscribed-msg" width="400"/>
   </li>
   <li>
      <strong>Event Creation:</strong> Enter an event title and date, then click "Create & Notify."<br>
      <img src="assets/event-created.png" alt="event-created" width="400"/>
   </li>
   <li>
      <strong>Verification:</strong> 
      <ul>
         <li>
            The subscriber will receive an email: <em>"New Event Added: [Title] on [Date]"</em>.<br>
            <img src="assets/aws-event-alert-email.png" alt="aws-event-alert-email" width="800"/>
         </li>
         <li>The S3 bucket will show an updated <code>events.json</code> file with the new entry.</li>
      </ul>
   </li>
</ol>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="roadmap">Roadmap</h2>
<ul>
   <li>[x] <strong>CORS Integration:</strong> Full API Gateway preflight support for cross-origin requests.</li>
   <li>[x] <strong>Dynamic Frontend:</strong> Terraform template injection for automatic API URL configuration.</li>
   <li>[x] <strong>Logging:</strong> CloudWatch Log Groups for Lambda and API Gateway debugging.</li>
   <li>[ ] <strong>SMS Support:</strong> Extend SNS to support mobile text notifications.</li>
   <li>[ ] <strong>Frontend Auth:</strong> Integrate AWS Cognito to secure the "Create Event" card.</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="challenges">Challenges</h2>
<table>
   <thead>
      <tr>
         <th>Challenge</th>
         <th>Solution</th>
      </tr>
   </thead>
   <tbody>
      <tr>
         <td><strong>CORS Preflight Failures</strong></td>
         <td>Implemented <code>aws_api_gateway_integration_response</code> for the <code>OPTIONS</code> method to explicitly return required headers to the browser.</td>
      </tr>
      <tr>
         <td><strong>S3 DNS Propagation</strong></td>
         <td>Encountered <code>no such host</code> during initial upload. Added <code>depends_on</code> blocks to ensure Bucket Policies are active before object upload.</td>
      </tr>
      <tr>
         <td><strong>Browser Caching</strong></td>
         <td>Utilized <code>etag = filemd5()</code> in Terraform for CSS/JS files to ensure the browser fetches the latest version after an update.</td>
      </tr>
      <tr>
         <td><strong>Decoupled States</strong></td>
         <td>Addressed the "Pending Confirmation" confusion by clarifying that SNS <code>Publish</code> can occur even if the specific subscriber hasn't opted in yet.</td>
      </tr>
   </tbody>
</table>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>
<h2 id="cost-optimization">Cost Optimization</h2>
<ul>
   <li><strong>100% Free Tier Eligible:</strong> Uses S3, Lambda, and SNS—all of which fall under the AWS Free Tier for low-volume usage.</li>
   <li><strong>Log Retention:</strong> CloudWatch logs are set to expire after 1 day to prevent storage costs from accumulating.</li>
   <li><strong>Tagging Strategy:</strong> Implemented <code>locals { common_tags }</code> to label all resources, making it easy to track costs in the AWS Billing Dashboard.</li>
</ul>
<div align="right"><a href="#readme-top">↑ Back to Top</a></div>

[contributors-shield]: https://img.shields.io/github/contributors/ShenLoong99/aws-terraform-event-announcement-system.svg?style=for-the-badge
[contributors-url]: https://github.com/ShenLoong99/aws-terraform-event-announcement-system/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ShenLoong99/aws-terraform-event-announcement-system.svg?style=for-the-badge
[forks-url]: https://github.com/ShenLoong99/aws-terraform-event-announcement-system/network/members
[stars-shield]: https://img.shields.io/github/stars/ShenLoong99/aws-terraform-event-announcement-system.svg?style=for-the-badge
[stars-url]: https://github.com/ShenLoong99/aws-terraform-event-announcement-system/stargazers
[issues-shield]: https://img.shields.io/github/issues/ShenLoong99/aws-terraform-event-announcement-system.svg?style=for-the-badge
[issues-url]: https://github.com/ShenLoong99/aws-terraform-event-announcement-system/issues
[license-shield]: https://img.shields.io/github/license/ShenLoong99/aws-terraform-event-announcement-system.svg?style=for-the-badge
[license-url]: https://github.com/ShenLoong99/aws-terraform-event-announcement-system/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/si-kai-tan
