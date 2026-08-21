<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quản lý mặt đứng & Drop Out — The Grand Manhattan</title>
<style>
  :root{
    --ink:#0f1a24; --panel:#16232f; --panel-2:#1c2b38; --line:#2a3d4d;
    --blueprint:#4fb3d9; --paper:#e8edf1; --muted:#7b93a3; --safety:#e8863a;
    --s0:#3b4a56; --s0-bg:#232f39;
    --s1:#e8b93a; --s1-bg:#3a3220;
    --s2:#4fb3d9; --s2-bg:#1b3340;
    --s3:#4caf6e; --s3-bg:#1c3327;
  }
  *{box-sizing:border-box;}
  body{margin:0;background:var(--ink);
    background-image:linear-gradient(var(--line) 1px, transparent 1px),linear-gradient(90deg, var(--line) 1px, transparent 1px);
    background-size:28px 28px;background-attachment:fixed;
    color:var(--paper);font-family:'Segoe UI', Roboto, Helvetica, Arial, sans-serif;min-height:100vh;}
  .wrap{max-width:1320px;margin:0 auto;padding:28px 20px 60px;}
  header{display:flex;justify-content:space-between;align-items:flex-end;border-bottom:2px solid var(--blueprint);padding-bottom:16px;margin-bottom:20px;flex-wrap:wrap;gap:14px;}
  .eyebrow{font-family:'Consolas','Courier New',monospace;letter-spacing:.18em;text-transform:uppercase;font-size:11px;color:var(--blueprint);margin:0 0 6px;}
  h1{margin:0;font-size:26px;font-weight:700;letter-spacing:.01em;}
  .sub{color:var(--muted);font-size:13px;margin-top:4px;}
  .overall{text-align:right;font-family:'Consolas','Courier New',monospace;}
  .overall .pct{font-size:34px;font-weight:700;color:var(--blueprint);line-height:1;}
  .overall .lbl{font-size:11px;color:var(--muted);letter-spacing:.1em;text-transform:uppercase;}

  .mainnav{display:flex;gap:8px;margin-bottom:18px;flex-wrap:wrap;}
  .mainnav button{background:var(--panel);border:1px solid var(--line);color:var(--muted);padding:9px 14px;border-radius:7px;cursor:pointer;font-size:12.5px;font-weight:600;white-space:nowrap;}
  .mainnav button.active{background:var(--blueprint);color:var(--ink);border-color:var(--blueprint);}
  .mainnav .sep{width:1px;background:var(--line);margin:4px 4px;}

  .legend{display:flex;gap:14px;flex-wrap:wrap;margin-bottom:18px;font-family:'Consolas','Courier New',monospace;font-size:11.5px;color:var(--muted);}
  .legend span{display:inline-flex;align-items:center;gap:6px;}
  .dot{width:10px;height:10px;border-radius:2px;display:inline-block;}

  .tabs{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:16px;}
  .tab{background:var(--panel);border:1px solid var(--line);color:var(--muted);padding:9px 14px;border-radius:6px 6px 0 0;cursor:pointer;font-family:'Consolas','Courier New',monospace;font-size:12.5px;display:flex;flex-direction:column;align-items:flex-start;gap:4px;min-width:118px;transition:.15s;}
  .tab .bar{width:100%;height:3px;background:var(--line);border-radius:2px;overflow:hidden;}
  .tab .bar i{display:block;height:100%;background:var(--muted);}
  .tab.active{background:var(--panel-2);color:var(--paper);border-color:var(--blueprint);}
  .tab:hover{color:var(--paper);}

  .panel{background:var(--panel-2);border:1px solid var(--line);border-radius:0 8px 8px 8px;padding:18px;}
  .panel.flat{border-radius:8px;}
  .axis-name{font-family:'Consolas','Courier New',monospace;color:var(--blueprint);font-size:13px;margin:0 0 2px;}
  .axis-note{color:var(--muted);font-size:12px;margin:0 0 16px;}

  table{width:100%;border-collapse:collapse;font-size:13.5px;}
  thead th{text-align:left;color:var(--muted);font-weight:600;font-size:11px;text-transform:uppercase;letter-spacing:.06em;border-bottom:1px solid var(--line);padding:6px 8px;}
  tbody td{padding:7px 8px;border-bottom:1px solid rgba(255,255,255,0.04);}
  tbody tr:hover{background:rgba(79,179,217,0.05);}
  .code{font-family:'Consolas','Courier New',monospace;font-weight:600;}
  .qty-input, .dim-input{width:64px;background:var(--panel);border:1px solid var(--line);color:var(--paper);border-radius:4px;padding:4px 6px;font-family:'Consolas','Courier New',monospace;text-align:center;}
  .dim-input:disabled, .qty-input:disabled{opacity:0.65;background:rgba(22,35,47,0.5);cursor:not-allowed;}
  .note-input{width:100%;background:transparent;border:none;border-bottom:1px dashed var(--line);color:var(--paper);font-size:12.5px;padding:3px 2px;}
  .note-input:focus{outline:none;border-bottom-color:var(--blueprint);}
  .task-input{width:100%;background:transparent;border:none;border-bottom:1px dashed var(--line);color:var(--paper);font-size:13px;padding:3px 2px;font-weight:600;}
  .task-input:focus{outline:none;border-bottom-color:var(--blueprint);}
  .date-input, .sel-input{background:var(--panel);border:1px solid var(--line);color:var(--paper);border-radius:4px;padding:4px 6px;font-family:'Consolas','Courier New',monospace;font-size:12px;}
  .status-text-input{width:100%;background:var(--panel);border:1px solid var(--line);color:var(--paper);border-radius:4px;padding:5px 8px;font-size:12.5px;}
  .status-text-input:focus{outline:none;border-color:var(--blueprint);}

  .status-btn{border:1px solid transparent;border-radius:5px;padding:5px 10px;font-family:'Consolas','Courier New',monospace;font-size:11px;font-weight:600;cursor:pointer;white-space:nowrap;transition:.12s;}
  .st-0{background:var(--s0-bg);color:var(--s0);border-color:var(--s0);}
  .st-1{background:var(--s1-bg);color:var(--s1);border-color:var(--s1);}
  .st-2{background:var(--s2-bg);color:var(--s2);border-color:var(--s2);}
  .st-3{background:var(--s3-bg);color:var(--s3);border-color:var(--s3);}
  .status-btn:active{transform:scale(0.96);}

  .barcell{display:flex;align-items:center;gap:8px;}
  .mini-bar{flex:1;height:8px;background:var(--panel);border-radius:4px;overflow:hidden;min-width:60px;}
  .mini-bar i{display:block;height:100%;background:var(--blueprint);}

  .row-add{margin-top:14px;display:flex;gap:8px;flex-wrap:wrap;}
  .row-add input, .row-add select{background:var(--panel);border:1px solid var(--line);color:var(--paper);border-radius:5px;padding:7px 10px;font-family:'Consolas','Courier New',monospace;font-size:12.5px;}
  .row-add input.code-in{width:130px;text-transform:uppercase;}
  .row-add input.qty-in, .row-add input.dim-in{width:80px;text-align:center;}
  .row-add button, .del-btn{background:transparent;border:1px solid var(--blueprint);color:var(--blueprint);border-radius:5px;padding:7px 14px;cursor:pointer;font-size:12.5px;font-family:inherit;}
  .row-add button:hover{background:var(--blueprint);color:var(--ink);}
  .del-btn{border-color:#8a3a3a;color:#d9756f;padding:4px 8px;}
  .del-btn:hover{background:#8a3a3a;color:var(--paper);}

  .subtask-container{background:rgba(0,0,0,0.18);padding:8px 12px;border-left:3px solid var(--blueprint);margin:6px 0;border-radius:0 6px 6px 0;font-size:12.5px;}
  .subtask-item{display:flex;align-items:center;gap:8px;margin:4px 0;}
  .subtask-item input[type="text"]{flex:1;background:transparent;border:none;border-bottom:1px dotted var(--line);color:var(--paper);padding:2px;}
  .subtask-item input[type="text"]:focus{outline:none;border-bottom-color:var(--blueprint);}
  .toggle-sub{background:var(--panel);border:1px solid var(--line);color:var(--blueprint);padding:2px 6px;border-radius:4px;font-size:11px;cursor:pointer;}

  .caveat{margin-top:20px;font-size:12px;color:var(--muted);border-top:1px dashed var(--line);padding-top:12px;line-height:1.6;}
  .caveat b{color:var(--safety);}
  footer{margin-top:26px;text-align:center;color:var(--muted);font-size:11px;font-family:'Consolas','Courier New',monospace;letter-spacing:.06em;}
</style>
</head>
<body>
<div class="wrap">

  <header>
    <div class="title-block">
      <p class="eyebrow">GMA.Q1 · Bản vẽ nhôm kính khối đế</p>
      <h1>Quản lý mặt đứng & Drop Out — The Grand Manhattan</h1>
      <p class="sub" id="subline">Quản lý tiến độ chi tiết tích hợp công tác con</p>
    </div>
    <div class="overall">
      <div class="pct" id="overallPct">0%</div>
      <div class="lbl" id="overallLbl">Tiến độ tổng thể</div>
    </div>
  </header>

  <div class="mainnav" id="mainnav"></div>

  <!-- ===== DEPARTMENT VIEW ===== -->
  <div id="viewDept">
    <div class="legend" id="legend"></div>

    <div class="panel flat" id="summaryPanel" style="margin-bottom:18px;">
      <p class="axis-name" id="summaryTitle">Tổng số khung</p>
      <table id="summaryTable">
        <thead id="summaryHead"></thead>
        <tbody id="summaryBody"></tbody>
      </table>
    </div>

    <div class="tabs" id="tabs"></div>
    <div class="panel" id="panelBody"></div>

    <div class="caveat">
      <b>Lưu ý:</b> Kích thước và Tổng SL tiêu chuẩn đã được khóa an toàn. Bạn có thể thêm mã tấm mới hoặc điều chỉnh số lượng đã hoàn thành bên dưới.
    </div>
  </div>

  <!-- ===== SCHEDULE VIEW ===== -->
  <div id="viewSchedule" style="display:none;">
    <div class="panel flat" style="margin-bottom:14px;">
      <p class="axis-name">Tiến độ thi công khối đế & Công tác con</p>
      <p class="axis-note">Quản lý các mốc công tác lớn, chi tiết các công tác con thành phần và trạng thái tùy chỉnh.</p>
      <table>
        <thead>
          <tr>
            <th style="width:4%">STT</th>
            <th style="width:26%">Tên công tác / Công tác con</th>
            <th style="width:11%">Phòng ban</th>
            <th style="width:9%">Khu vực</th>
            <th style="width:8%">Bắt đầu</th>
            <th style="width:8%">Kết thúc</th>
            <th style="width:14%">% Hoàn thành</th>
            <th style="width:16%">Trạng thái (Tự điền)</th>
            <th style="width:4%"></th>
          </tr>
        </thead>
        <tbody id="scheduleBody"></tbody>
      </table>
      <div class="row-add">
        <input type="text" id="newTask" class="task-input" placeholder="Tên công tác lớn mới" style="width:220px">
        <button onclick="addTask()">+ Thêm công tác lớn</button>
      </div>
    </div>
  </div>

  <footer>TRẦN MINH HIẾU · THIẾT KẾ PODIUM 2026 · TRACKING TOOL</footer>
</div>

<script>
// Tích hợp đường dẫn Google Apps Script Web App của bạn
const GOOGLE_SHEET_WEB_APP_URL = "https://script.google.com/macros/s/AKfycbyLG0ZI1pu62bjjyCOSqHIGq_dEuY_JuapggWcCOK4_k_3XYOjXOFT0Ape4kqLOzMwfOw/exec";

// Hàm gửi thông tin cô đọng khi có thay đổi
function syncToGoogleSheet(deptId, panelCode, statusDesc) {
  if (!GOOGLE_SHEET_WEB_APP_URL.startsWith("http")) return;
  
  const payload = {
    dept: DEPT_MAP[deptId] ? DEPT_MAP[deptId].name : deptId,
    code: panelCode,
    changeText: statusDesc
  };

  fetch(GOOGLE_SHEET_WEB_APP_URL, {
    method: "POST",
    mode: "no-cors",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  }).catch(err => {
    console.error("Lỗi đồng bộ Google Sheet:", err);
  });
}
const ELEVATIONS = [
  { id:"EL1", label:"EL (1)", axis:"Trục 1X7 ~ 1X1", type:"el", note:"Đã cập nhật kích thước chuẩn bản vẽ.",
    panels:[
      {code:"EWS-3",qty:4,w:2120,h:2530},{code:"EWS-30",qty:4,w:1800,h:5000},{code:"EWS-3A",qty:4,w:2120,h:2450},
      {code:"EWS-43",qty:18,w:1800,h:2000},{code:"EWS-44",qty:6,w:1800,h:1750}
    ]
  },
  { id:"EL2", label:"EL (2)", axis:"Trục 1X1 ~ 1X9", type:"el", note:"Đã nội suy và hoàn thiện danh mục tấm chuẩn.",
    panels:[
      {code:"EWS-02",qty:4,w:2350,h:4750},{code:"EWS-3",qty:6,w:2120,h:2530},{code:"EWS-3A",qty:6,w:2120,h:2450},
      {code:"EWS-30",qty:12,w:1800,h:5000},{code:"EWS-45",qty:36,w:1800,h:2000},{code:"EWS-45A",qty:4,w:1800,h:1750},
      {code:"EWS-46",qty:4,w:1400,h:2000},{code:"EWS-48",qty:8,w:1800,h:1650},{code:"LVWS-2",qty:1,w:8000,h:5850}
    ]
  },
  { id:"EL3", label:"EL (3)", axis:"Trục 1Y11 ~ 1Y1", type:"el", note:"Đã cập nhật chuẩn theo bản vẽ EL 3.",
    panels:[
      {code:"EWS-14",qty:28,w:2430,h:2000},{code:"EWS-14A",qty:2,w:2430,h:1750},{code:"EWS-15",qty:6,w:1500,h:2000},{code:"EWS-2",qty:2,w:2350,h:4750},
      {code:"EWS-20",qty:3,w:1500,h:1700},{code:"EWS-21",qty:12,w:2430,h:1700},{code:"EWS-22",qty:2,w:2430,h:1700},{code:"EWS-23",qty:3,w:1500,h:1750},
      {code:"EWS-24",qty:8,w:2430,h:1750},{code:"EWS-25",qty:4,w:2430,h:1750},{code:"EWS-26",qty:6,w:1550,h:1600},{code:"EWS-27",qty:2,w:1550,h:1950},
      {code:"EWS-3",qty:7,w:2120,h:2530},{code:"EWS-31",qty:3,w:1500,h:5000},{code:"EWS-32",qty:8,w:2430,h:5000},{code:"EWS-33",qty:2,w:4400,h:4600},
      {code:"EWS-34",qty:1,w:1800,h:4600},{code:"EWS-35",qty:2,w:2430,h:5000},{code:"EWS-3A",qty:5,w:2120,h:2450},{code:"EWS-3B",qty:2,w:2120,h:2450},
      {code:"EWS-5",qty:2,w:1300,h:2530},{code:"EWS-5A",qty:2,w:1300,h:2450},{code:"EWS-6.1A",qty:1,w:1200,h:2450}
    ]
  },
  { id:"EL4", label:"EL (4)", axis:"Trục 1Y1 ~ 1Y11", type:"el", note:"Đã cập nhật chuẩn theo bản vẽ EL 4.",
    panels:[
      {code:"EWD-01",qty:1,w:800,h:2200},{code:"EWD-02",qty:1,w:1670,h:2650},{code:"EWD-03",qty:1,w:2630,h:2650},{code:"EWS-12",qty:11,w:1670,h:2000},
      {code:"EWS-14",qty:2,w:2430,h:2000},{code:"EWS-17",qty:4,w:1670,h:1700},{code:"EWS-19",qty:1,w:2430,h:1630},{code:"EWS-28A",qty:1,w:1400,h:1850},
      {code:"EWS-28B",qty:3,w:1400,h:2000},{code:"EWS-36",qty:1,w:2120,h:2780},{code:"EWS-36A",qty:1,w:2120,h:1800},{code:"EWS-41",qty:1,w:2100,h:2000},
      {code:"EWS-45B",qty:7,w:1800,h:1900},{code:"EWS-48",qty:7,w:1800,h:1650},{code:"EWS-5",qty:2,w:1300,h:2530},{code:"EWS-5A",qty:2,w:1300,h:2450},
      {code:"EWS-6.1B",qty:1,w:1200,h:2450},{code:"EWS-7",qty:2,w:2120,h:2530},{code:"EWS-7A",qty:1,w:2120,h:2450},{code:"EWS-7B",qty:1,w:2120,h:2450},
      {code:"LVWS-1",qty:1,w:6600,h:5850}
    ]
  },
  { id:"EL5", label:"EL (5)", axis:"Trục 2Y4 ~ 2Y1", type:"el", note:"Đã cập nhật chuẩn theo bản vẽ EL 5.",
    panels:[
      {code:"EWS-3",qty:4,w:2120,h:2530},{code:"EWS-37",qty:3,w:2100,h:5000},{code:"EWS-3A-1",qty:4,w:2120,h:2370},{code:"EWS-49",qty:6,w:2100,h:2000},
      {code:"EWS-50",qty:2,w:2100,h:1750},{code:"EWS-51",qty:3,w:1350,h:2000},{code:"EWS-52",qty:1,w:1600,h:1850},{code:"EWS-6.1",qty:1,w:1200,h:2350},
      {code:"EWS-6.1A-1",qty:1,w:1200,h:2370},{code:"EWS-8",qty:1,w:1700,h:2530},{code:"EWS-8A-1",qty:1,w:1700,h:2450}
    ]
  },
  {
    id: "EL6",
    label: "EL (6)",
    axis: "Trục 2X1 ~ 2X9",
    type: "el",
    note: "Đã nội suy và hoàn thiện danh mục tấm chuẩn khối đế.",
    panels: [
      { code: "AD-01", qty: 1, w: 1200, h: 2530 },
      { code: "EWS-2_A1", qty: 2, w: 2650, h: 4770 },
      { code: "EWS-2_A2", qty: 2, w: 2650, h: 4770 },
      { code: "EWS-3", qty: 5, w: 2120, h: 2530 },
      { code: "EWS-30", qty: 8, w: 1800, h: 5000 },
      { code: "EWS-38", qty: 4, w: 1800, h: 5000 },
      { code: "EWS-39", qty: 1, w: 1260, h: 5000 },
      { code: "EWS-3A", qty: 4, w: 2120, h: 2450 },
      { code: "EWS-3B", qty: 1, w: 2120, h: 2450 },
      { code: "EWS-43", qty: 29, w: 1800, h: 2000 },
      { code: "EWS-44", qty: 2, w: 1800, h: 1750 },
      { code: "EWS-45", qty: 27, w: 1800, h: 2000 },
      { code: "EWS-46", qty: 2, w: 1400, h: 2000 },
      { code: "EWS-46A", qty: 1, w: 1260, h: 2000 },
      { code: "EWS-48A", qty: 9, w: 1800, h: 1525 },
      { code: "EWS-54", qty: 9, w: 1800, h: 1750 },
      { code: "EWS-55", qty: 1, w: 1600, h: 2000 },
      { code: "EWS-56", qty: 1, w: 1600, h: 1525 },
      { code: "EWS-58", qty: 1, w: 1400, h: 1650 },
      { code: "EWS-6.1", qty: 1, w: 1200, h: 2350 },
      { code: "EWS-6.1A", qty: 1, w: 1200, h: 2450 },
      { code: "EWS-9", qty: 1, w: 5760, h: 2450 },
      { code: "EWS-9A", qty: 1, w: 5760, h: 2530 },
      { code: "LVWS-10", qty: 1, w: 4900, h: 2530 },
      { code: "LVWS-10A", qty: 1, w: 4900, h: 2450 },
      { code: "LVWS-3", qty: 1, w: 3500, h: 2530 },
      { code: "LVWS-3-1", qty: 1, w: 3800, h: 5850 },
      { code: "LVWS-3A", qty: 2, w: 3500, h: 2450 },
      { code: "LVWS-4", qty: 1, w: 3500, h: 5250 },
      { code: "LVWS-7", qty: 1, w: 5200, h: 2530 },
      { code: "LVWS-7A", qty: 1, w: 5200, h: 2450 },
      { code: "LVWS-8", qty: 1, w: 3200, h: 2530 },
      { code: "LVWS-8A", qty: 1, w: 3200, h: 2450 },
      { code: "LVWS-9", qty: 1, w: 2300, h: 2530 },
      { code: "LVWS-9A", qty: 1, w: 2300, h: 2450 }
    ]
  },
  { id:"EL7", label:"EL (7)", axis:"Trục 2X12 ~ 2X1", type:"el", note:"Đã cập nhật chuẩn theo bản vẽ EL 7.",
    panels:[
      {code:"EWS-10",qty:1,w:5000,h:2530},{code:"EWS-10A",qty:1,w:5000,h:2450},{code:"EWS-11",qty:1,w:3500,h:2530},{code:"EWS-11B",qty:1,w:3500,h:2450},
      {code:"EWS-3",qty:9,w:2120,h:2530},{code:"EWS-30",qty:12,w:1800,h:5000},{code:"EWS-3A",qty:2,w:2120,h:2450},{code:"EWS-3A-2",qty:6,w:2120,h:2310},
      {code:"EWS-3B",qty:1,w:2120,h:2450},{code:"EWS-43",qty:24,w:1800,h:2000},{code:"EWS-44",qty:5,w:1800,h:1750},{code:"EWS-5",qty:1,w:1300,h:2530},
      {code:"EWS-54",qty:5,w:1800,h:1750},{code:"EWS-55",qty:12,w:1600,h:2000},{code:"EWS-57",qty:4,w:1600,h:1525},{code:"EWS-5B-2",qty:1,w:1300,h:2450},
      {code:"EWS-6.1",qty:2,w:1200,h:2350},{code:"EWS-6.1A-2",qty:3,w:1200,h:2310}
    ]
  },
  { id:"DROPOUT", label:"Drop Out", axis:"Khu vực kỹ thuật / Khe thoáng", type:"dropout", note:"Danh mục tấm theo bản vẽ Drop Out chi tiết.",
    panels:[
      {code:"CW-25",qty:1,w:7500,h:2540},{code:"CW-25-1",qty:1,w:7500,h:1190},
      {code:"CW-25a",qty:1,w:7500,h:2540},{code:"CW-25a-1",qty:1,w:7500,h:1190},
      {code:"CW-26",qty:2,w:3600,h:2540},{code:"CW-26-1",qty:2,w:3600,h:1190},
      {code:"CW-27",qty:1,w:3600,h:2540},{code:"CW-27-1",qty:1,w:3600,h:1190},
      {code:"CW-30",qty:1,w:6160,h:2540},{code:"CW-30-1",qty:1,w:6160,h:1190},
      {code:"CW-31",qty:1,w:4800,h:2540},{code:"CW-31-1",qty:1,w:4800,h:1190}
    ]
  }
];

const DEPARTMENTS = [
  { id:"design",    name:"Phòng Thiết kế",    short:"Thiết kế",    statuses:["Chưa triển khai","Đang triển khai","Đã hoàn thành bản vẽ","Đã duyệt phát hành"] },
  { id:"boq",       name:"Phòng Thống kê",    short:"Thống kê",     statuses:["Chưa bóc khối lượng","Đang bóc khối lượng","Đã bóc xong","Đã kiểm tra chéo"] },
  { id:"qs",        name:"Phòng QS",          short:"QS",           statuses:["Chưa đo bóc","Đang đo bóc / kiểm tra","Đã xác nhận khối lượng","Đã nghiệm thu thanh toán"] },
  { id:"purchase",   name:"Phòng Mua hàng",    short:"Mua hàng",     statuses:["Chưa đặt hàng","Đã đặt hàng (PO)","Đã về kho","Đã cấp cho xưởng"] },
  { id:"workshop",   name:"Xưởng Gia công",    short:"Xưởng",        statuses:["Chưa gia công","Đang gia công","Gia công xong","Đã xuất xưởng"] },
  { id:"sitework",   name:"Phòng Thi công",    short:"Thi công",     statuses:["Chưa bắt đầu","Đang lắp dựng","Đã lắp dựng","Đã nghiệm thu"] },
];
const DEPT_MAP = Object.fromEntries(DEPARTMENTS.map(d=>[d.id,d]));

const DEFAULT_TASKS = [
  {task:"Lắp dựng EL(1) — Trục 1X7~1X1", dept:"sitework", el:"EL1", pct:0, start:"", end:"", statusText:"Đang triển khai", subtasks:[
    {name:"Khảo sát mặt bằng & thả tuyến", done:true},
    {name:"Lắp đặt bas/bracket neo", done:false},
    {name:"Lắp dựng các khung nhôm EWS", done:false}
  ]},
  {task:"Lắp dựng Drop Out — Khu kỹ thuật", dept:"sitework", el:"DROPOUT", pct:0, start:"", end:"", statusText:"Chuẩn bị vật tư", subtasks:[
    {name:"Gia công kết cấu thép phụ", done:true},
    {name:"Lắp đặt các khung CW", done:false}
  ]},
];

const STORE_KEY = "gma_facade_tracker_v17";
let state = null;
let activeTab = ELEVATIONS[0].id;
let mainView = "sitework";
let expandedSubtasks = {};

function freshPanel(code, qty, w=0, h=0){
  const stages = {};
  DEPARTMENTS.forEach(d=>{ stages[d.id] = {status:0, note:"", qtyDone:0}; });
  return {code, qty, w, h, stages};
}

function defaultState(){
  const s = { elevations:{}, tasks: DEFAULT_TASKS.map(t=>({...t, subtasks: t.subtasks.map(st=>({...st}))})) };
  ELEVATIONS.forEach(el=>{ s.elevations[el.id] = { panels: el.panels.map(p=>freshPanel(p.code,p.qty,p.w||0,p.h||0)) }; });
  return s;
}

function loadState(){
  try{
    const savedData = localStorage.getItem(STORE_KEY);
    if(savedData){
      state = JSON.parse(savedData);
      ELEVATIONS.forEach(el=>{
        if(!state.elevations[el.id]){
          state.elevations[el.id] = { panels: el.panels.map(p=>freshPanel(p.code,p.qty,p.w||0,p.h||0)) };
        }
      });
      state.tasks.forEach(t=>{ if(t.statusText === undefined) t.statusText = ""; });
    } else {
      state = defaultState();
      saveState();
    }
  }catch(e){
    state = defaultState();
  }
  render();
}

function saveState(){
  try{ 
    localStorage.setItem(STORE_KEY, JSON.stringify(state)); 
    syncToGoogleSheet(); // Tự động gửi về Google Sheet khi có thay đổi
  }catch(e){}
}

function elProgress(deptId, elId){
  const panels = state.elevations[elId]?.panels || [];
  if(panels.length===0) return 0;
  let total = 0, done = 0;
  panels.forEach(p=>{
    total += Number(p.qty) || 0;
    const s = p.stages[deptId] || {qtyDone:0, status:0};
    let q = s.qtyDone !== undefined ? Number(s.qtyDone) || 0 : (s.status===3 ? (Number(p.qty) || 0) : 0);
    done += Math.min(Number(p.qty) || 0, Math.max(0, q));
  });
  return total===0 ? 0 : Math.round((done/total)*100);
}

function deptOverallProgress(deptId){
  let total=0, done=0;
  Object.keys(state.elevations).forEach(elId=>{
    state.elevations[elId].panels.forEach(p=>{
      total += Number(p.qty) || 0;
      const s = p.stages[deptId] || {qtyDone:0, status:0};
      let q = s.qtyDone !== undefined ? Number(s.qtyDone) || 0 : (s.status===3 ? (Number(p.qty) || 0) : 0);
      done += Math.min(Number(p.qty) || 0, Math.max(0, q));
    });
  });
  return total===0 ? 0 : Math.round((done/total)*100);
}

function taskPct(t){
  if(t.subtasks && t.subtasks.length>0){
    const done = t.subtasks.filter(s=>s.done).length;
    return Math.round((done/t.subtasks.length)*100);
  }
  return (t.dept && t.el) ? elProgress(t.dept, t.el) : (t.pct||0);
}

function scheduleProgress(){
  if(state.tasks.length===0) return 0;
  return Math.round(state.tasks.reduce((a,t)=>a+taskPct(t),0)/state.tasks.length);
}

function switchView(v){
  mainView = v;
  document.getElementById("viewDept").style.display = v==="schedule" ? "none":"block";
  document.getElementById("viewSchedule").style.display = v==="schedule" ? "block":"none";
  if(v==="schedule"){
    document.getElementById("overallLbl").textContent = "Tiến độ tổng thể (công tác)";
  } else {
    document.getElementById("overallLbl").textContent = "Tiến độ — " + DEPT_MAP[v].name;
  }
  render();
}

function renderMainNav(){
  const nav = document.getElementById("mainnav");
  let html = DEPARTMENTS.map(d=>`<button class="${mainView===d.id?'active':''}" onclick="switchView('${d.id}')">${d.name}</button>`).join("");
  html += `<span class="sep"></span><button class="${mainView==='schedule'?'active':''}" onclick="switchView('schedule')">Tiến độ khối đế</button>`;
  nav.innerHTML = html;
}

function renderLegend(){
  const dept = DEPT_MAP[mainView];
  const legend = document.getElementById("legend");
  if(!dept){ legend.innerHTML=""; return; }
  legend.innerHTML = dept.statuses.map((lbl,i)=>`<span><i class="dot" style="background:var(--s${i})"></i>${lbl}</span>`).join("") +
    `<span style="color:var(--paper)">— Bấm vào trạng thái để chuyển vòng</span>`;
}

function renderTabs(){
  const tabsEl = document.getElementById("tabs");
  tabsEl.innerHTML = "";
  ELEVATIONS.forEach(el=>{
    const pct = elProgress(mainView, el.id);
    const div = document.createElement("div");
    div.className = "tab" + (el.id===activeTab ? " active":"");
    div.innerHTML = `<span>${el.label}</span><span style="color:var(--muted);font-size:10.5px">${el.type==='dropout'?'Drop Out':'Mặt đứng'}</span><div class="bar"><i style="width:${pct}%"></i></div><span style="font-size:10.5px">${pct}%</span>`;
    div.onclick = ()=>{ activeTab = el.id; render(); };
    tabsEl.appendChild(div);
  });
}

function renderSummary(){
  const dept = DEPT_MAP[mainView];
  const isQS = (mainView === 'qs');
  document.getElementById("summaryTitle").textContent = isQS ? "Tổng hợp khối lượng & Diện tích — Phòng QS" : "Tổng hợp khối lượng — " + dept.name;
  const head = document.getElementById("summaryHead");
  
  if(isQS){
    head.innerHTML = `<tr>
      <th>Khu vực / Mặt đứng</th>
      <th style="text-align:right">Tổng khung</th>
      <th style="text-align:right">SL Đã xong</th>
      <th style="text-align:right">Tổng diện tích</th>
      <th style="text-align:right">% Hoàn thành</th>
      ${dept.statuses.map(l=>`<th style="text-align:right">${l}</th>`).join("")}
    </tr>`;
  } else {
    head.innerHTML = `<tr>
      <th>Khu vực / Mặt đứng</th>
      <th style="text-align:right">Tổng khung</th>
      <th style="text-align:right">SL Đã xong</th>
      <th style="text-align:right">% Hoàn thành</th>
      ${dept.statuses.map(l=>`<th style="text-align:right">${l}</th>`).join("")}
    </tr>`;
  }

  const body = document.getElementById("summaryBody");
  let rows = "";
  let gTot=0, gDone=0, gArea=0, gC=[0,0,0,0];

  ELEVATIONS.forEach(el=>{
    const panels = state.elevations[el.id]?.panels || [];
    let tot=0, done=0, area=0, c=[0,0,0,0];
    panels.forEach(p=>{
      const qVal = Number(p.qty) || 0;
      tot += qVal;
      const pArea = ((Number(p.w) || 0) * (Number(p.h) || 0) * qVal) / 1000000;
      area += pArea;
      const s = p.stages[dept.id] || {qtyDone:0, status:0};
      let q = s.qtyDone !== undefined ? Number(s.qtyDone) || 0 : (s.status===3 ? qVal : 0);
      const safeQ = Math.min(qVal, Math.max(0, q));
      done += safeQ;
      
      const stIdx = Number(s.status) || 0;
      c[stIdx] += qVal;
    });
    gTot += tot; gDone += done; gArea += area;
    c.forEach((v,i)=>gC[i]+=v);
    const pct = tot === 0 ? 0 : Math.round((done / tot) * 100);

    if(isQS){
      rows += `<tr>
        <td class="code">${el.label}</td>
        <td style="text-align:right">${tot}</td>
        <td style="text-align:right; color:var(--s3); font-weight:600;">${done}</td>
        <td style="text-align:right; font-family:'Consolas','Courier New',monospace; color:var(--blueprint); font-weight:600;">${area.toFixed(2)} m²</td>
        <td style="text-align:right; font-weight:600;">${pct}%</td>
        ${c.map((v,i)=>`<td style="text-align:right;color:var(--s${i})">${v}</td>`).join("")}
      </tr>`;
    } else {
      rows += `<tr>
        <td class="code">${el.label}</td>
        <td style="text-align:right">${tot}</td>
        <td style="text-align:right; color:var(--s3); font-weight:600;">${done}</td>
        <td style="text-align:right; font-weight:600;">${pct}%</td>
        ${c.map((v,i)=>`<td style="text-align:right;color:var(--s${i})">${v}</td>`).join("")}
      </tr>`;
    }
  });

  const gPct = gTot === 0 ? 0 : Math.round((gDone / gTot) * 100);
  if(isQS){
    rows += `<tr style="font-weight:700;border-top:1px solid var(--blueprint)">
      <td class="code">TỔNG</td>
      <td style="text-align:right">${gTot}</td>
      <td style="text-align:right; color:var(--s3);">${gDone}</td>
      <td style="text-align:right; color:var(--blueprint);">${gArea.toFixed(2)} m²</td>
      <td style="text-align:right">${gPct}%</td>
      ${gC.map((v,i)=>`<td style="text-align:right;color:var(--s${i})">${v}</td>`).join("")}
    </tr>`;
  } else {
    rows += `<tr style="font-weight:700;border-top:1px solid var(--blueprint)">
      <td class="code">TỔNG</td>
      <td style="text-align:right">${gTot}</td>
      <td style="text-align:right; color:var(--s3);">${gDone}</td>
      <td style="text-align:right">${gPct}%</td>
      ${gC.map((v,i)=>`<td style="text-align:right;color:var(--s${i})">${v}</td>`).join("")}
    </tr>`;
  }
  body.innerHTML = rows;
}

function cycleStatus(elId, idx){
  const p = state.elevations[elId].panels[idx];
  const s = p.stages[mainView];
  s.status = (s.status+1)%4;
  if(s.status === 3) s.qtyDone = p.qty;
  else if(s.status === 0) s.qtyDone = 0;
  
  // Gọi đẩy dữ liệu gọn về Google Sheet
  syncToGoogleSheet(mainView, p.code, "Chuyển trạng thái: " + DEPT_MAP[mainView].statuses[s.status]);
  
  saveState(); render();
}

function updateQtyDone(elId, idx, val){
  const n = parseInt(val,10);
  const p = state.elevations[elId].panels[idx];
  const s = p.stages[mainView];
  s.qtyDone = isNaN(n)?0:Math.min(p.qty, Math.max(0, n));
  if(s.qtyDone === p.qty) s.status = 3;
  else if(s.qtyDone > 0) s.status = 2;
  else s.status = 0;
  
  // Gọi đẩy dữ liệu gọn về Google Sheet
  syncToGoogleSheet(mainView, p.code, "Cập nhật SL xong: " + s.qtyDone + "/" + p.qty);
  
  saveState(); render();
}

function updateNote(elId, idx, val){ state.elevations[elId].panels[idx].stages[mainView].note = val; saveState(); }
function deletePanel(elId, idx){ state.elevations[elId].panels.splice(idx,1); saveState(); render(); }
function addPanel(elId){
  const codeIn=document.getElementById("newCode"), qtyIn=document.getElementById("newQty");
  const wIn=document.getElementById("newW"), hIn=document.getElementById("newH");
  const code=codeIn.value.trim().toUpperCase(); 
  const qty=parseInt(qtyIn.value,10)||1;
  const w=wIn?parseInt(wIn.value,10)||0:0;
  const h=hIn?parseInt(hIn.value,10)||0:0;
  if(!code) return;
  state.elevations[elId].panels.push(freshPanel(code, qty, w, h));
  codeIn.value=""; qtyIn.value="1"; if(wIn) wIn.value=""; if(hIn) hIn.value=""; 
  saveState(); render();
}

function renderPanel(){
  const el = ELEVATIONS.find(e=>e.id===activeTab);
  const dept = DEPT_MAP[mainView];
  const body = document.getElementById("panelBody");
  const panels = state.elevations[el.id]?.panels || [];
  const isQS = (mainView === 'qs');
  
  let rows = panels.map((p,idx)=>{
    const s = p.stages[dept.id] || {status:0, note:"", qtyDone:0};
    const qDone = s.qtyDone !== undefined ? s.qtyDone : (s.status===3 ? p.qty : 0);
    const rowPct = p.qty === 0 ? 0 : Math.round((qDone / p.qty) * 100);
    const area = ((p.w || 0) * (p.h || 0) * p.qty) / 1000000;

    if(isQS){
      return `<tr>
        <td class="code">${p.code}</td>
        <td><input type="number" class="dim-input" value="${p.w || ''}" disabled></td>
        <td><input type="number" class="dim-input" value="${p.h || ''}" disabled></td>
        <td><input type="number" class="qty-input" value="${p.qty}" disabled></td>
        <td style="font-family:'Consolas','Courier New',monospace; color:var(--blueprint); font-weight:600;">${area.toFixed(2)} m²</td>
        <td><input type="number" class="qty-input" value="${qDone}" min="0" max="${p.qty}" onchange="updateQtyDone('${el.id}',${idx},this.value)" style="color:var(--s3); font-weight:600;"></td>
        <td style="font-weight:600;">${rowPct}%</td>
        <td><button class="status-btn st-${s.status}" onclick="cycleStatus('${el.id}',${idx})">${dept.statuses[s.status]}</button></td>
        <td><input type="text" class="note-input" placeholder="Ghi chú..." value="${(s.note||'').replace(/"/g,'&quot;')}" onchange="updateNote('${el.id}',${idx},this.value)"></td>
        <td><button class="del-btn" onclick="deletePanel('${el.id}',${idx})" title="Xoá">✕</button></td>
      </tr>`;
    } else {
      return `<tr>
        <td class="code">${p.code}</td>
        <td><input type="number" class="dim-input" value="${p.w || ''}" disabled></td>
        <td><input type="number" class="dim-input" value="${p.h || ''}" disabled></td>
        <td><input type="number" class="qty-input" value="${p.qty}" disabled></td>
        <td><input type="number" class="qty-input" value="${qDone}" min="0" max="${p.qty}" onchange="updateQtyDone('${el.id}',${idx},this.value)" style="color:var(--s3); font-weight:600;"></td>
        <td style="font-weight:600;">${rowPct}%</td>
        <td><button class="status-btn st-${s.status}" onclick="cycleStatus('${el.id}',${idx})">${dept.statuses[s.status]}</button></td>
        <td><input type="text" class="note-input" placeholder="Ghi chú..." value="${(s.note||'').replace(/"/g,'&quot;')}" onchange="updateNote('${el.id}',${idx},this.value)"></td>
        <td><button class="del-btn" onclick="deletePanel('${el.id}',${idx})" title="Xoá">✕</button></td>
      </tr>`;
    }
  }).join("");

  const colspanVal = isQS ? 10 : 9;
  if(panels.length===0) rows = `<tr><td colspan="${colspanVal}" style="color:var(--muted);padding:16px 8px;">Chưa có mã tấm nào.</td></tr>`;
  
  let theadHTML = "";
  if(isQS){
    theadHTML = `<tr>
      <th style="width:15%">Mã tấm</th>
      <th style="width:9%">Rộng (mm)</th>
      <th style="width:9%">Cao (mm)</th>
      <th style="width:9%">Tổng SL</th>
      <th style="width:11%">Diện tích (m²)</th>
      <th style="width:9%">SL Đã xong</th>
      <th style="width:8%">% Hoàn thành</th>
      <th style="width:16%">Trạng thái</th>
      <th style="width:18%">Ghi chú / Thuyết minh</th>
      <th style="width:4%"></th>
    </tr>`;
  } else {
    theadHTML = `<tr>
      <th style="width:18%">Mã tấm</th>
      <th style="width:10%">Rộng (mm)</th>
      <th style="width:10%">Cao (mm)</th>
      <th style="width:10%">Tổng SL</th>
      <th style="width:10%">SL Đã xong</th>
      <th style="width:8%">% Hoàn thành</th>
      <th style="width:18%">Trạng thái</th>
      <th style="width:18%">Ghi chú / Thuyết minh</th>
      <th style="width:8%"></th>
    </tr>`;
  }

  body.innerHTML = `<p class="axis-name">${el.label} — ${el.axis}</p>
    <p class="axis-note">${el.note || ''}</p>
    <table><thead>${theadHTML}</thead><tbody>${rows}</tbody></table>
    <div class="row-add">
      <input type="text" id="newCode" class="code-in" placeholder="Mã tấm mới">
      <input type="number" id="newW" class="dim-in" placeholder="Rộng mm">
      <input type="number" id="newH" class="dim-in" placeholder="Cao mm">
      <input type="number" id="newQty" class="qty-in" value="1" min="1" placeholder="SL">
      <button onclick="addPanel('${el.id}')">+ Thêm mã tấm</button>
    </div>`;
}

function renderSchedule(){
  const body = document.getElementById("scheduleBody");
  if(state.tasks.length===0){
    body.innerHTML = `<tr><td colspan="9" style="color:var(--muted);padding:16px;">Chưa có công tác nào.</td></tr>`;
    return;
  }
  let html = "";
  state.tasks.forEach((t, i)=>{
    const p = taskPct(t);
    const isExpanded = expandedSubtasks[i];
    html += `<tr>
      <td class="code">${i+1}</td>
      <td>
        <div style="display:flex;align-items:center;gap:6px;">
          <input type="text" class="task-input" value="${t.task.replace(/"/g,'&quot;')}" onchange="updateTaskField(${i},'task',this.value)">
          ${t.subtasks && t.subtasks.length>0 ? `<button class="toggle-sub" onclick="toggleSub(${i})">${isExpanded ? 'Ẩn con' : 'DS con('+t.subtasks.length+')'}</button>`:''}
        </div>
      </td>
      <td><select class="sel-input" onchange="updateTaskField(${i},'dept',this.value)">
        <option value="">-- Chọn PB --</option>
        ${DEPARTMENTS.map(d=>`<option value="${d.id}" ${t.dept===d.id?'selected':''}>${d.short}</option>`).join('')}
      </select></td>
      <td><select class="sel-input" onchange="updateTaskField(${i},'el',this.value)">
        <option value="">-- Khu vực --</option>
        ${ELEVATIONS.map(e=>`<option value="${e.id}" ${t.el===e.id?'selected':''}>${e.label}</option>`).join('')}
      </select></td>
      <td><input type="text" class="date-input" value="${t.start||''}" onchange="updateTaskField(${i},'start',this.value)"></td>
      <td><input type="text" class="date-input" value="${t.end||''}" onchange="updateTaskField(${i},'end',this.value)"></td>
      <td>
        <div class="barcell">
          <div class="mini-bar"><i style="width:${p}%"></i></div>
          <span style="font-family:'Consolas','Courier New',monospace;font-size:12px">${p}%</span>
        </div>
      </td>
      <td><input type="text" class="status-text-input" value="${(t.statusText||'').replace(/"/g,'&quot;')}" placeholder="Trạng thái..." onchange="updateTaskField(${i},'statusText',this.value)"></td>
      <td><button class="del-btn" onclick="deleteTask(${i})" title="Xoá">✕</button></td>
    </tr>`;

    if(isExpanded && t.subtasks){
      html += `<tr><td colspan="9" style="background:rgba(0,0,0,0.12);padding:0;"><div class="subtask-container">`;
      t.subtasks.forEach((st, stIdx)=>{
        html += `<div class="subtask-item">
          <input type="checkbox" ${st.done?'checked':''} onchange="toggleSubtask(${i},${stIdx})">
          <input type="text" value="${st.name.replace(/"/g,'&quot;')}" onchange="updateSubtaskName(${i},${stIdx},this.value)" placeholder="Tên công tác con...">
          <button class="del-btn" style="padding:2px 6px;font-size:10px" onclick="deleteSubtask(${i},${stIdx})">Xoá con</button>
        </div>`;
      });
      html += `<div style="margin-top:6px;display:flex;gap:6px;">
        <input type="text" id="newSub_${i}" placeholder="Thêm công tác con mới..." style="flex:1;background:var(--panel);border:1px solid var(--line);color:var(--paper);padding:3px 6px;border-radius:4px;font-size:12px;">
        <button class="row-add button" style="padding:3px 8px;font-size:11px;" onclick="addSubtask(${i})">+ Thêm con</button>
      </div></div></td></tr>`;
    }
  });
  body.innerHTML = html;
}

function updateTaskField(i, field, val){ state.tasks[i][field] = val; saveState(); render(); }
function deleteTask(i){ state.tasks.splice(i,1); saveState(); render(); }
function addTask(){
  const inp = document.getElementById("newTask");
  const val = inp.value.trim();
  if(!val) return;
  state.tasks.push({task:val, dept:"", el:"", pct:0, start:"", end:"", statusText:"Chưa bắt đầu", subtasks:[{name:"Khảo sát / Chuẩn bị", done:false}]});
  inp.value = ""; saveState(); render();
}
function toggleSub(i){ expandedSubtasks[i] = !expandedSubtasks[i]; render(); }
function toggleSubtask(i, stIdx){ state.tasks[i].subtasks[stIdx].done = !state.tasks[i].subtasks[stIdx].done; saveState(); render(); }
function updateSubtaskName(i, stIdx, val){ state.tasks[i].subtasks[stIdx].name = val; saveState(); }
function deleteSubtask(i, stIdx){ state.tasks[i].subtasks.splice(stIdx,1); saveState(); render(); }
function addSubtask(i){
  const inp = document.getElementById("newSub_" + i);
  if(!inp || !inp.value.trim()) return;
  if(!state.tasks[i].subtasks) state.tasks[i].subtasks = [];
  state.tasks[i].subtasks.push({name: inp.value.trim(), done: false});
  saveState(); render();
}

function render(){
  renderMainNav();
  renderLegend();
  if(mainView === 'schedule'){
    document.getElementById("overallPct").textContent = scheduleProgress() + "%";
    renderSchedule();
  } else {
    document.getElementById("overallPct").textContent = deptOverallProgress(mainView) + "%";
    renderTabs();
    renderSummary();
    renderPanel();
  }
}

loadState();
</script>
</body>
</html>
