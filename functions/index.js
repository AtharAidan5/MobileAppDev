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
sgMail.setApiKey(process.env.SENDGRID_API_KEY || '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'); // Use env variable or placeholder

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
      from: 'noreply@yourdomain.com', // Use your verified sender
      subject: `Your certificate "${after.name}" was ${after.status}`,
      text: `Hello,\n\nYour certificate "${after.name}" has been ${after.status}.\n\nYou can view it here: https://yourapp.com/view/${after.shareToken}\n\nBest regards,\nCertify App Team`,
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
