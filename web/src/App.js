import logo from './logo.svg';
import './App.css';

function App() {
  const handleShowAlert = () => {
    console.log('Bridge对象:', window.Bridge); // 检查Bridge是否存在
    console.log('webkit对象:', window.webkit); // 检查webkit是否存在
    
    if (window.Bridge) {
      try {
        window.Bridge.showAlert('Hello from Web!');
        console.log('消息已发送');
      } catch (error) {
        console.error('发送消息时出错:', error);
      }
    } else {
      console.error('Bridge未初始化');
    }
  };

  return (
    <div className="App">
      <button style={{ width: '100px', height: '100px' }} onClick={e => handleShowAlert()}>Show Native Alert</button>
    </div>
  );
}

export default App;
