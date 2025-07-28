import React from 'react';

const PrivacyPolicy: React.FC = () => {
  return (
    <main style={{ maxWidth: 800, margin: 'auto', padding: 40, fontFamily: 'sans-serif', lineHeight: 1.6, color: '#b4b2b2ff' }}>
      <h1 style={{ color: '#0077cc' }}>Privacy Policy</h1>
      <p>Last updated: July 28, 2025</p>

      <h2 style={{ color: '#0077cc' }}>1. Introduction</h2>
      <p>This app was developed by Matteo Boschetti. Your privacy is important to us. This page explains how we collect, use, and protect your personal data.</p>

      <h2 style={{ color: '#0077cc' }}>2. Data We Collect</h2>
      <p>The app may collect the following information:</p>
      <ul>
        <li>Contact details (e.g., email), if voluntarily provided</li>
        <li>Anonymous usage data to improve the app</li>
        <li>Location data, only if explicitly authorized</li>
      </ul>

      <h2 style={{ color: '#0077cc' }}>3. Purpose of Data Collection</h2>
      <p>The data we collect is used for:</p>
      <ul>
        <li>Providing app functionality</li>
        <li>Improving user experience</li>
        <li>Technical communication (e.g., bug reports, updates)</li>
      </ul>

      <h2 style={{ color: '#0077cc' }}>4. Third-Party Services</h2>
      <p>The app may use third-party services, such as:</p>
      <ul>
        <li>Carto for map features</li>
      </ul>
      <p>These services may collect data as per their own privacy policies.</p>

      <h2 style={{ color: '#0077cc' }}>5. Consent</h2>
      <p>The app will request your explicit consent before collecting or using any sensitive information. You may revoke consent at any time by uninstalling the app or contacting us directly.</p>

      <h2 style={{ color: '#0077cc' }}>6. Your Rights</h2>
      <p>Under the EU General Data Protection Regulation (GDPR), you have the right to:</p>
      <ul>
        <li>Access your data</li>
        <li>Request correction or deletion of your data</li>
        <li>Withdraw your consent</li>
      </ul>

      <h2 style={{ color: '#0077cc' }}>7. Data Security</h2>
      <p>We implement appropriate technical and organizational measures to protect your data against unauthorized access.</p>

      <h2 style={{ color: '#0077cc' }}>8. Contact</h2>
      <p>If you have any questions or concerns about this policy, you can contact us at:</p>
      <p><strong>Email:</strong> mboschetti03@gmail.com</p>

      <h2 style={{ color: '#0077cc' }}>9. Changes to This Policy</h2>
      <p>This policy may be updated from time to time. We recommend reviewing it periodically.</p>
    </main>
  );
};

export default PrivacyPolicy;
