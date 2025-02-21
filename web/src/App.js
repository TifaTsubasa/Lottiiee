import logo from './logo.svg';
import './App.css';

function App() {
  const handleGetVersion = async () => {
    console.log('Bridge对象:', window.Bridge);
    console.log('webkit对象:', window.webkit);
    
    if (window.Bridge) {
      try {
        const result = await window.Bridge.getVersion();
        console.log('应用版本信息:', result);
        alert(`App版本: ${result.version}\n构建版本: ${result.build}`);
      } catch (error) {
        console.error('获取版本信息时出错:', error);
      }
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
