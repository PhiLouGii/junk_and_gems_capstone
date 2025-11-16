import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider } from './contexts/ThemeContext';
import ThemeToggle from './components/ThemeToggle/ThemeToggle';
import Home from './components/Home/Home'; 
import LearnMore from './components/LearnMore/LearnMore';
import UpcycledProductsGallery from './components/UpcycledProductsGallery/UpcycledProductsGallery';
import TermsAndConditions from './components/Legal/TermsAndConditions';
import PrivacyPolicy from './components/Legal/PrivacyPolicy';
import './App.css';
import './styles/darkmode.css'; 

const App: React.FC = () => {
  return (
    <ThemeProvider>
      <Router>
        <div className="App">
          <Routes>
            <Route path="/" element={<Home />} /> 
            <Route path="/learn-more" element={<LearnMore />} /> 
            <Route path="/upcycled-products" element={<UpcycledProductsGallery />} />
            <Route path="/terms" element={<TermsAndConditions />} />
            <Route path="/privacy" element={<PrivacyPolicy />} />
          </Routes>
          <ThemeToggle />
        </div>
      </Router>
    </ThemeProvider>
  );
};

export default App;