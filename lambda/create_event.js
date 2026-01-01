const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const s3 = new S3Client();
const sns = new SNSClient();

exports.handler = async (event) => {
    const bucket = process.env.S3_BUCKET;
    const key = 'events.json';
    const body = JSON.parse(event.body); // Expects { "title": "...", "date": "..." }

    try {
        // 1. Get existing events
        const data = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }));
        const currentContent = await data.Body.transformToString();
        let events = JSON.parse(currentContent);

        // 2. Add new event
        events.push(body);

        // 3. Upload updated list back to S3
        await s3.send(new PutObjectCommand({
            Bucket: bucket,
            Key: key,
            Body: JSON.stringify(events),
            ContentType: 'application/json'
        }));

        // 4. Send SNS Notification
        await sns.send(new PublishCommand({
            TopicArn: process.env.SNS_TOPIC_ARN,
            Message: `New Event Added: ${body.title} on ${body.date}`,
            Subject: "New Event Alert!"
        }));

        return {
            statusCode: 200,
            headers: { "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({ message: "Event created and notification sent!" })
        };
    } catch (err) {
        console.error(err);
        return { 
            statusCode: 500, 
            headers: { 
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ error: err.message }) 
        };
    }
};