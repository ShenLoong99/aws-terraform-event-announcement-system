const { SNSClient, SubscribeCommand } = require("@aws-sdk/client-sns");
const sns = new SNSClient();

exports.handler = async (event) => {
    const { email } = JSON.parse(event.body);
    await sns.send(new SubscribeCommand({
        Protocol: 'email',
        TopicArn: process.env.SNS_TOPIC_ARN,
        Endpoint: email
    }));
    return {
        statusCode: 200,
        headers: {
            "Access-Control-Allow-Origin": "*", // Required for CORS
            "Access-Control-Allow-Methods": "POST,OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        body: JSON.stringify({ message: "Subscribed successfully!" }),
    };
};