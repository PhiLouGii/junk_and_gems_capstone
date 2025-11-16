import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './components/Home/Home'; 
import LearnMore from './components/LearnMore/LearnMore';
import UpcycledProductsGallery from './components/UpcycledProductsGallery/UpcycledProductsGallery';
import './App.css';

const App: React.FC = () => {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<Home />} /> 
          <Route path="/learn-more" element={<LearnMore />} /> 
          <Route path="/upcycled-products" element={<UpcycledProductsGallery />} />
        </Routes>
      </div>
    </Router>
  );
};

export default App;