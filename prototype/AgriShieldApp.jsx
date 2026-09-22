/**
 * AgriShield — UI vision prototype (React + Tailwind CSS).
 *
 * This is a look-and-feel reference spanning ALL THREE roadmap versions
 * (see /docs/roadmap) in one screen. It is NOT wired to a backend: every
 * number shown ("AgriShield Rating 780/900", "$248.50" wallet balance,
 * "Active Policy #AS-8921", claim/loan entries) is hardcoded sample data
 * for layout purposes only, not a real farmer record or transaction.
 *
 * Feature-to-version mapping (see /docs/roadmap for full detail):
 *   - Home / AI Crop Diagnostic tabs -> V1 (hackathon demo) + V2
 *   - Parametric Shield (insurance) tab -> V3, no underwriter partner confirmed
 *   - AgriWallet & BNPL (finance) tab -> V3, no lender partner confirmed
 *   - Market & Inputs tab -> V2 (price feed) extended into V3 (marketplace/BNPL)
 *
 * The "AgriShield Rating" shown here is the V2 data-driven reliability
 * score concept, not a certified financial credit score.
 */
import React, { useState } from 'react';
import {
  Shield, AlertTriangle, Camera, CheckCircle2, TrendingUp,
  Wallet, ShoppingBag, CloudRain, MapPin, ChevronRight,
  Scan, Leaf, ArrowUpRight, DollarSign, Award, RefreshCw
} from 'lucide-react';

export default function AgriShieldApp() {
  const [activeTab, setActiveTab] = useState('home');
  const [isScanning, setIsScanning] = useState(false);
  const [scanResult, setScanResult] = useState(null);

  // Simulated AI Leaf Scan Action
  const handleScan = () => {
    setIsScanning(true);
    setScanResult(null);
    setTimeout(() => {
      setIsScanning(false);
      setScanResult({
        disease: 'Maize Northern Leaf Blight',
        confidence: 94,
        severity: 'Moderate',
        treatment: 'Apply Copper Hydroxide or Azoxystrobin fungicide within 5 days.',
        recommendedProduct: 'ShieldFungicide Pro 500ml',
        productPrice: '$18.50'
      });
    }, 2000);
  };

  return (
    <div className="max-w-md mx-auto bg-slate-900 text-slate-100 min-h-screen flex flex-col font-sans pb-20 border-x border-slate-800 shadow-2xl">

      {/* TOP HEADER */}
      <header className="p-4 bg-slate-900/90 backdrop-blur sticky top-0 z-50 border-b border-slate-800 flex justify-between items-center">
        <div className="flex items-center space-x-2">
          <div className="p-2 bg-emerald-500/10 rounded-xl border border-emerald-500/30">
            <Shield className="w-6 h-6 text-emerald-400" />
          </div>
          <div>
            <h1 className="font-bold text-lg leading-tight tracking-wide text-white">AgriShield</h1>
            <p className="text-xs text-emerald-400 font-medium">Climate & Yield Resilience</p>
          </div>
        </div>
        <div className="flex items-center space-x-2 bg-slate-800/80 px-3 py-1.5 rounded-full border border-slate-700">
          <MapPin className="w-3.5 h-3.5 text-emerald-400" />
          <span className="text-xs text-slate-300 font-medium">Harare South</span>
        </div>
      </header>

      {/* DYNAMIC MAIN CONTENT */}
      <main className="flex-1 p-4 space-y-4">

        {/* ----------------- TAB 1: SHIELD HUB (HOME) ----------------- */}
        {activeTab === 'home' && (
          <div className="space-y-4">

            {/* FARMER PROFILE & SHIELD SCORE */}
            <div className="bg-gradient-to-br from-emerald-950/60 to-slate-900 p-5 rounded-2xl border border-emerald-500/20 shadow-lg relative overflow-hidden">
              <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-500/5 rounded-full blur-2xl pointer-events-none"></div>
              <div className="flex justify-between items-start mb-4">
                <div>
                  <span className="text-xs font-semibold uppercase tracking-wider text-emerald-400 bg-emerald-500/10 px-2.5 py-1 rounded-md border border-emerald-500/20">
                    Verified Smallholder
                  </span>
                  <h2 className="text-xl font-bold text-white mt-2">Tendai Moyo</h2>
                  <p className="text-xs text-slate-400">4.5 Hectares • Maize & Soybeans</p>
                </div>
                <div className="text-right bg-slate-900/80 p-2.5 rounded-xl border border-slate-800">
                  <div className="flex items-center space-x-1 text-emerald-400 justify-end">
                    <Award className="w-4 h-4" />
                    <span className="text-lg font-extrabold">780</span>
                    <span className="text-xs text-slate-500">/900</span>
                  </div>
                  <span className="text-[10px] text-slate-400 font-medium">AgriShield Rating</span>
                </div>
              </div>

              {/* CLIMATE RISK ALERT BANNER */}
              <div className="bg-amber-500/10 border border-amber-500/30 rounded-xl p-3 flex items-start space-x-3">
                <AlertTriangle className="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-xs font-semibold text-amber-300">Pest Alert: Fall Armyworm Hazard</h4>
                  <p className="text-[11px] text-amber-200/80 mt-0.5">High probability detected in Sector 4. Inspect maize crop immediately.</p>
                </div>
              </div>
            </div>

            {/* QUICK ACTIONS GRID */}
            <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider px-1">Quick Services</h3>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setActiveTab('health')}
                className="bg-slate-800/60 hover:bg-slate-800 p-4 rounded-xl border border-slate-700/60 flex flex-col items-start justify-between text-left transition group"
              >
                <div className="p-2.5 bg-emerald-500/10 rounded-lg text-emerald-400 group-hover:scale-105 transition">
                  <Camera className="w-5 h-5" />
                </div>
                <div className="mt-3">
                  <span className="text-sm font-semibold text-white block">AI Crop Diagnostic</span>
                  <span className="text-[11px] text-slate-400">Scan leaves for disease</span>
                </div>
              </button>

              <button
                onClick={() => setActiveTab('insurance')}
                className="bg-slate-800/60 hover:bg-slate-800 p-4 rounded-xl border border-slate-700/60 flex flex-col items-start justify-between text-left transition group"
              >
                <div className="p-2.5 bg-sky-500/10 rounded-lg text-sky-400 group-hover:scale-105 transition">
                  <CloudRain className="w-5 h-5" />
                </div>
                <div className="mt-3">
                  <span className="text-sm font-semibold text-white block">Parametric Shield</span>
                  <span className="text-[11px] text-slate-400">Drought & rain insurance</span>
                </div>
              </button>

              <button
                onClick={() => setActiveTab('finance')}
                className="bg-slate-800/60 hover:bg-slate-800 p-4 rounded-xl border border-slate-700/60 flex flex-col items-start justify-between text-left transition group"
              >
                <div className="p-2.5 bg-indigo-500/10 rounded-lg text-indigo-400 group-hover:scale-105 transition">
                  <Wallet className="w-5 h-5" />
                </div>
                <div className="mt-3">
                  <span className="text-sm font-semibold text-white block">AgriWallet & BNPL</span>
                  <span className="text-[11px] text-slate-400">$450 Credit pre-approved</span>
                </div>
              </button>

              <button
                onClick={() => setActiveTab('market')}
                className="bg-slate-800/60 hover:bg-slate-800 p-4 rounded-xl border border-slate-700/60 flex flex-col items-start justify-between text-left transition group"
              >
                <div className="p-2.5 bg-amber-500/10 rounded-lg text-amber-400 group-hover:scale-105 transition">
                  <ShoppingBag className="w-5 h-5" />
                </div>
                <div className="mt-3">
                  <span className="text-sm font-semibold text-white block">Market & Inputs</span>
                  <span className="text-[11px] text-slate-400">Live prices & buyers</span>
                </div>
              </button>
            </div>

            {/* LIVE FIELD PARAMETERS */}
            <div className="bg-slate-800/40 p-4 rounded-xl border border-slate-800 space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-xs font-semibold text-slate-300">Satellite Index (Field #1)</span>
                <span className="text-xs text-emerald-400 font-medium">Updated 2h ago</span>
              </div>
              <div className="grid grid-cols-3 gap-2 text-center">
                <div className="bg-slate-900/80 p-2.5 rounded-lg border border-slate-800">
                  <span className="text-[10px] text-slate-400 block">NDVI Moisture</span>
                  <span className="text-sm font-bold text-emerald-400">0.72 (Healthy)</span>
                </div>
                <div className="bg-slate-900/80 p-2.5 rounded-lg border border-slate-800">
                  <span className="text-[10px] text-slate-400 block">Soil Moisture</span>
                  <span className="text-sm font-bold text-sky-400">34%</span>
                </div>
                <div className="bg-slate-900/80 p-2.5 rounded-lg border border-slate-800">
                  <span className="text-[10px] text-slate-400 block">7-Day Rainfall</span>
                  <span className="text-sm font-bold text-white">42 mm</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ----------------- TAB 2: AI CROP DIAGNOSTIC ----------------- */}
        {activeTab === 'health' && (
          <div className="space-y-4">
            <div className="bg-slate-800/60 p-4 rounded-xl border border-slate-700/60">
              <h3 className="text-sm font-bold text-white">AI Computer Vision Leaf Diagnostic</h3>
              <p className="text-xs text-slate-400 mt-1">Take or upload a clear photo of crop leaf lesions for instant identification.</p>
            </div>

            {/* SIMULATED CAMERA VIEWPORT */}
            <div className="relative bg-slate-950 rounded-2xl border-2 border-dashed border-emerald-500/40 p-8 text-center flex flex-col items-center justify-center overflow-hidden min-h-[220px]">
              {isScanning ? (
                <div className="flex flex-col items-center space-y-3">
                  <RefreshCw className="w-10 h-10 text-emerald-400 animate-spin" />
                  <span className="text-xs text-emerald-300 font-medium animate-pulse">Running Neural Vision Model...</span>
                </div>
              ) : (
                <>
                  <div className="p-4 bg-emerald-500/10 rounded-full text-emerald-400 mb-3 border border-emerald-500/20">
                    <Scan className="w-8 h-8" />
                  </div>
                  <span className="text-xs font-semibold text-slate-300">Position crop leaf in target box</span>
                  <button
                    onClick={handleScan}
                    className="mt-4 bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold px-5 py-2.5 rounded-xl text-xs flex items-center space-x-2 transition shadow-lg shadow-emerald-500/20"
                  >
                    <Camera className="w-4 h-4" />
                    <span>Run AI Diagnostic Scan</span>
                  </button>
                </>
              )}
            </div>

            {/* SCAN RESULTS DISPLAY */}
            {scanResult && (
              <div className="bg-slate-800/80 p-4 rounded-2xl border border-emerald-500/40 space-y-3 animate-fade-in">
                <div className="flex justify-between items-start border-b border-slate-700/60 pb-3">
                  <div>
                    <span className="text-[10px] font-bold text-amber-400 bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/20">
                      Detected Hazard
                    </span>
                    <h4 className="text-base font-bold text-white mt-1">{scanResult.disease}</h4>
                  </div>
                  <span className="text-xs font-bold text-emerald-400 bg-emerald-500/10 px-2 py-1 rounded-md">
                    {scanResult.confidence}% Match
                  </span>
                </div>

                <div className="space-y-2 text-xs">
                  <div>
                    <span className="text-slate-400 font-medium">Recommended Treatment:</span>
                    <p className="text-slate-200 mt-0.5 bg-slate-900/60 p-2 rounded-lg border border-slate-800">{scanResult.treatment}</p>
                  </div>
                </div>

                <div className="pt-2 flex items-center justify-between bg-emerald-950/40 p-3 rounded-xl border border-emerald-500/20">
                  <div>
                    <span className="text-[10px] text-emerald-300 font-medium block">Verified Input Available</span>
                    <span className="text-xs font-bold text-white">{scanResult.recommendedProduct} ({scanResult.productPrice})</span>
                  </div>
                  <button className="bg-emerald-500 hover:bg-emerald-600 text-slate-950 text-xs font-bold px-3 py-1.5 rounded-lg transition">
                    Order Input
                  </button>
                </div>
              </div>
            )}
          </div>
        )}

        {/* ----------------- TAB 3: PARAMETRIC INSURANCE ----------------- */}
        {activeTab === 'insurance' && (
          <div className="space-y-4">
            <div className="bg-gradient-to-r from-sky-950/60 to-slate-900 p-5 rounded-2xl border border-sky-500/30">
              <div className="flex justify-between items-start">
                <div>
                  <span className="text-[10px] font-bold text-sky-400 bg-sky-500/10 px-2 py-0.5 rounded border border-sky-500/20">
                    Active Policy #AS-8921
                  </span>
                  <h3 className="text-base font-bold text-white mt-1">Drought & Moisture Index Cover</h3>
                  <p className="text-xs text-slate-400 mt-0.5">Coverage: $1,200 • Premium: $45 (Subsidized)</p>
                </div>
                <CloudRain className="w-8 h-8 text-sky-400" />
              </div>

              {/* AUTOMATED PAYOUT TRIGGER METER */}
              <div className="mt-4 pt-3 border-t border-sky-500/20 space-y-2">
                <div className="flex justify-between text-xs">
                  <span className="text-slate-300">Seasonal Rainfall Index</span>
                  <span className="text-sky-300 font-bold">180 mm / 220 mm Trigger</span>
                </div>
                <div className="w-full bg-slate-800 h-2.5 rounded-full overflow-hidden">
                  <div className="bg-sky-400 h-full rounded-full" style={{ width: '81%' }}></div>
                </div>
                <p className="text-[11px] text-slate-400">Automatic payout of $350 triggers if rainfall drops below 150 mm by Day 45.</p>
              </div>
            </div>

            <div className="bg-slate-800/40 p-4 rounded-xl border border-slate-800 space-y-2">
              <h4 className="text-xs font-bold text-white">Recent Claims Ledger</h4>
              <div className="flex justify-between items-center text-xs p-2.5 bg-slate-900/80 rounded-lg border border-slate-800">
                <div className="flex items-center space-x-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  <div>
                    <span className="font-semibold text-white block">Dry Spell Payout</span>
                    <span className="text-[10px] text-slate-400">Mobile Transfer #EC-9012</span>
                  </div>
                </div>
                <span className="font-bold text-emerald-400">+$180.00</span>
              </div>
            </div>
          </div>
        )}

        {/* ----------------- TAB 4: AGRIFINANCE & WALLET ----------------- */}
        {activeTab === 'finance' && (
          <div className="space-y-4">
            {/* WALLET CARD */}
            <div className="bg-slate-800 p-5 rounded-2xl border border-slate-700 space-y-4">
              <div className="flex justify-between items-center">
                <span className="text-xs text-slate-400 font-medium">AgriWallet Balance</span>
                <span className="text-xs text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded font-semibold">Verified ID</span>
              </div>
              <div>
                <h2 className="text-3xl font-extrabold text-white">$248.50</h2>
                <p className="text-xs text-slate-400 mt-1">Available EcoCash / Mobile Money</p>
              </div>

              <div className="grid grid-cols-2 gap-2 pt-2">
                <button className="bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold text-xs py-2.5 rounded-xl transition">
                  Deposit / Cash In
                </button>
                <button className="bg-slate-700 hover:bg-slate-600 text-white font-bold text-xs py-2.5 rounded-xl transition">
                  Withdraw
                </button>
              </div>
            </div>

            {/* BNPL CREDIT LIMIT */}
            <div className="bg-slate-800/40 p-4 rounded-xl border border-slate-800 space-y-3">
              <div className="flex justify-between items-center">
                <h4 className="text-xs font-bold text-white">Pay-at-Harvest Input Credit (BNPL)</h4>
                <span className="text-xs text-indigo-400 font-bold">$450 Limit</span>
              </div>
              <p className="text-xs text-slate-400">Buy certified seeds and fertilizers now; repay when selling crops to verified off-takers.</p>
              <button className="w-full bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 text-xs font-bold py-2.5 rounded-xl transition flex items-center justify-center space-x-1">
                <span>Apply for Seed Input Loan</span>
                <ArrowUpRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}

        {/* ----------------- TAB 5: MARKETPLACE ----------------- */}
        {activeTab === 'market' && (
          <div className="space-y-4">
            <div className="bg-slate-800/60 p-4 rounded-xl border border-slate-700/60">
              <h3 className="text-sm font-bold text-white">Regional Commodity Spot Prices</h3>
              <p className="text-xs text-slate-400 mt-0.5">Live verified buyer price benchmarks per Tonne.</p>
            </div>

            <div className="space-y-2">
              <div className="bg-slate-800/40 p-3 rounded-xl border border-slate-800 flex justify-between items-center">
                <div>
                  <h4 className="text-xs font-bold text-white">White Maize (Grade A)</h4>
                  <span className="text-[10px] text-slate-400">Harare Grain Market</span>
                </div>
                <div className="text-right">
                  <span className="text-sm font-bold text-emerald-400">$290 / Tonne</span>
                  <span className="text-[10px] text-emerald-400/80 block flex items-center justify-end"><TrendingUp className="w-3 h-3 mr-0.5" /> +2.4%</span>
                </div>
              </div>

              <div className="bg-slate-800/40 p-3 rounded-xl border border-slate-800 flex justify-between items-center">
                <div>
                  <h4 className="text-xs font-bold text-white">Soybeans</h4>
                  <span className="text-[10px] text-slate-400">Gweru Off-taker Hub</span>
                </div>
                <div className="text-right">
                  <span className="text-sm font-bold text-emerald-400">$480 / Tonne</span>
                  <span className="text-[10px] text-slate-400 block">Stable</span>
                </div>
              </div>
            </div>
          </div>
        )}

      </main>

      {/* BOTTOM NAVIGATION BAR */}
      <nav className="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-slate-900/95 backdrop-blur border-t border-slate-800 grid grid-cols-5 p-2 gap-1 z-50">
        <button
          onClick={() => setActiveTab('home')}
          className={`flex flex-col items-center py-1.5 rounded-xl transition ${activeTab === 'home' ? 'text-emerald-400 bg-emerald-500/10' : 'text-slate-400 hover:text-slate-200'}`}
        >
          <Shield className="w-5 h-5" />
          <span className="text-[10px] mt-1 font-medium">Home</span>
        </button>

        <button
          onClick={() => setActiveTab('health')}
          className={`flex flex-col items-center py-1.5 rounded-xl transition ${activeTab === 'health' ? 'text-emerald-400 bg-emerald-500/10' : 'text-slate-400 hover:text-slate-200'}`}
        >
          <Camera className="w-5 h-5" />
          <span className="text-[10px] mt-1 font-medium">Health</span>
        </button>

        <button
          onClick={() => setActiveTab('insurance')}
          className={`flex flex-col items-center py-1.5 rounded-xl transition ${activeTab === 'insurance' ? 'text-sky-400 bg-sky-500/10' : 'text-slate-400 hover:text-slate-200'}`}
        >
          <CloudRain className="w-5 h-5" />
          <span className="text-[10px] mt-1 font-medium">Shield</span>
        </button>

        <button
          onClick={() => setActiveTab('finance')}
          className={`flex flex-col items-center py-1.5 rounded-xl transition ${activeTab === 'finance' ? 'text-indigo-400 bg-indigo-500/10' : 'text-slate-400 hover:text-slate-200'}`}
        >
          <Wallet className="w-5 h-5" />
          <span className="text-[10px] mt-1 font-medium">Finance</span>
        </button>

        <button
          onClick={() => setActiveTab('market')}
          className={`flex flex-col items-center py-1.5 rounded-xl transition ${activeTab === 'market' ? 'text-amber-400 bg-amber-500/10' : 'text-slate-400 hover:text-slate-200'}`}
        >
          <ShoppingBag className="w-5 h-5" />
          <span className="text-[10px] mt-1 font-medium">Market</span>
        </button>
      </nav>

    </div>
  );
}
