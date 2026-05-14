import React from 'react';

const Support: React.FC = () => {
  return (
    <main style={{ maxWidth: 800, margin: 'auto', padding: 40, fontFamily: 'sans-serif', lineHeight: 1.6, color: '#b4b2b2ff' }}>
      <h1 style={{ color: '#0077cc' }}>Splash – Support</h1>
      <p>Need help with Splash? You are in the right place.</p>

      <h2 style={{ color: '#0077cc' }}>Contact</h2>
      <p>For bug reports, questions, feedback or account issues, write us at:</p>
      <p><strong>Email:</strong> <a href="mailto:mboschetti03@gmail.com" style={{ color: '#0077cc' }}>mboschetti03@gmail.com</a></p>
      <p>We usually reply within 48 hours.</p>

      <h2 style={{ color: '#0077cc' }}>Frequently Asked Questions</h2>

      <h3 style={{ color: '#0077cc' }}>What is Splash?</h3>
      <p>Splash is a collaborative map of public drinking water fountains. Find fountains around you, add new ones with a photo and report issues. The data is built and updated by the community.</p>

      <h3 style={{ color: '#0077cc' }}>The app cannot see my position. What can I do?</h3>
      <p>Splash needs location permission to show the fountains near you. Go to your device Settings, find Splash and make sure location access is enabled. You can choose "While Using the App" for the best balance between privacy and accuracy.</p>

      <h3 style={{ color: '#0077cc' }}>I added a fountain but I do not see it on the map.</h3>
      <p>New fountains may take a few seconds to appear after creation. Pull down on the map to refresh. If it still does not show up, please contact us with the fountain name and approximate location.</p>

      <h3 style={{ color: '#0077cc' }}>I found wrong information on a fountain.</h3>
      <p>Open the fountain detail page and tap "Report". Select the reason (wrong info, wrong image, wrong potability, fountain does not exist) and send the report. Our moderators review reports within a few days.</p>

      <h3 style={{ color: '#0077cc' }}>How do I save my favorite fountains?</h3>
      <p>Open a fountain and tap "Save". You can find all your saved fountains in the Saved section of the app. You need to be logged in to use this feature.</p>

      <h3 style={{ color: '#0077cc' }}>How do I delete my account or my data?</h3>
      <p>Send us an email at mboschetti03@gmail.com from the address associated with your account. We will delete your account and all related personal data within 7 days.</p>

      <h3 style={{ color: '#0077cc' }}>The app crashes or behaves strangely.</h3>
      <p>Try closing and reopening the app. If the problem persists, please send us an email with your device model, iOS version and a short description of the issue. A screenshot helps a lot.</p>

      <h2 style={{ color: '#0077cc' }}>More</h2>
      <p>
        <a href="/privacy-policy" style={{ color: '#0077cc' }}>Privacy Policy</a> &nbsp;·&nbsp;
        <a href="/terms-of-service" style={{ color: '#0077cc' }}>Terms of Service</a>
      </p>
    </main>
  );
};

export default Support;
