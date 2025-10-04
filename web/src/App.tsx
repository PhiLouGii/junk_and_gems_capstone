import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LearnMore from './components/LearnMore/LearnMore';
import BrowseMaterials from './components/BrowseMaterials/BrowseMaterials';
import './App.css';

const App: React.FC = () => {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<LearnMore />} />
          <Route path="/browse-materials" element={<BrowseMaterials />} />
        </Routes>
      </div>
    </Router>
  );
};

export default App;