/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

// SendGrid API Key Configuration
// For development: Use environment variable or direct key
// For production: Always use environment variables
const sendGridApiKey = process.env.SENDGRID_API_KEY || 'YOUR_SENDGRID_API_KEY';
sgMail.setApiKey(sendGridApiKey);

// TODO: For production deployment, set environment variable:
// firebase functions:config:set sendgrid.api_key="YOUR_SENDGRID_API_KEY"

exports.sendCertificateStatusEmail = functions.firestore
  .document('certificates/{certId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only send email if status changed to approved or rejected
    if (before.status === after.status) return null;
    if (!['approved', 'rejected'].includes(after.status)) return null;

    const recipientEmail = after.recipientEmail || after.recipient; // Adjust field as needed
    if (!recipientEmail) return null;

    const msg = {
      to: recipientEmail,
      from: 'noreply@certifyapp.com', // Update this to your verified sender domain
      subject: `Certificate Status Update: "${after.name}"`,
      text: `Hello,\n\nYour certificate "${after.name}" has been ${after.status}.\n\nYou can view it here: https://certifyapp.com/view/${after.shareToken}\n\nBest regards,\nCertify App Team`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Certificate Status Update</h2>
          <p>Hello,</p>
          <p>Your certificate <strong>"${after.name}"</strong> has been <strong>${after.status}</strong>.</p>
          <p>You can view your certificate by clicking the link below:</p>
          <a href="https://certifyapp.com/view/${after.shareToken}" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">View Certificate</a>
          <p style="margin-top: 20px;">Best regards,<br>Certify App Team</p>
        </div>
      `,
    };

    try {
      await sgMail.send(msg);
      console.log('Email sent to', recipientEmail);
    } catch (error) {
      console.error('Error sending email:', error);
    }
    return null;
  });

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
