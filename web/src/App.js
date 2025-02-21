import logo from './logo.svg';
import './App.css';

function App() {
  const handleGetVersion = async () => {
    console.log('webkit对象:', window.webkit);
    console.log('handle对象:', window.webkit.messageHandlers);
    console.log('bridge对象:', window.bridge);
    
    if (window.bridge) {
      window.bridge.callSwift(
        "callSwiftFunction",
        { value: "Hello from React!" },
        (response) => {
          alert("Received from Swift:" + response);
          console.log("Received from Swift:", response);
        }
      );
    } else {
      console.error('Bridge未初始化');
    }
  };

  return (
    <div className="App">
      <button style={{ width: '200px', height: '50px' }} onClick={handleGetVersion}>
        获取应用版本
      </button>
    </div>
  );
}

export default App;
