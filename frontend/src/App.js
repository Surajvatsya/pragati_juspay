import React, { useState, } from 'react';
import { v4 as uuidv4 } from 'uuid';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import './App.css';
import colleges from './colleges.json'; // Import the JSON data present in src



function App() {
  const [applicants, setApplicants] = useState([]);
  const [submitted, setSubmitted] = useState(false); // State to track form submission
  const [selectedDate, setSelectedDate] = useState(null); 
  const genderOptions = ["Male", "Female", "Non-binary", "Prefer not to say"];
  const [selectedCollege, setSelectedCollege] = useState("");
  const [customCollege, setCustomCollege] = useState("");

  
const yearsOfExperience = Array.from({ length: 41 }, (_, i) => i); // Assuming a range of 0-40 years
const monthsOfExperience = Array.from({ length: 12 }, (_, i) => i);


  // List of country codes
  const countryCodes = {
    "Afghanistan": "+93",
    "Albania": "+355",
    "Algeria": "+213",
    "Andorra": "+376",
    "Angola": "+244",
    "Antigua and Barbuda": "+1 268",
    "Argentina": "+54",
    "Armenia": "+374",
    "Australia": "+61",
    "Austria": "+43",
    "Azerbaijan": "+994",
    "Bahamas": "+1 242",
    "Bahrain": "+973",
    "Bangladesh": "+880",
    "Barbados": "+1 246",
    "Belarus": "+375",
    "Belgium": "+32",
    "Belize": "+501",
    "Benin": "+229",
    "Bhutan": "+975",
    "Bolivia": "+591",
    "Bosnia and Herzegovina": "+387",
    "Botswana": "+267",
    "Brazil": "+55",
    "Brunei": "+673",
    "Bulgaria": "+359",
    "Burkina Faso": "+226",
    "Burundi": "+257",
    "Cabo Verde": "+238",
    "Cambodia": "+855",
    "Cameroon": "+237",
    "Canada": "+1",
    "Central African Republic": "+236",
    "Chad": "+235",
    "Chile": "+56",
    "China": "+86",
    "Colombia": "+57",
    "Comoros": "+269",
    "Congo, Democratic Republic of the": "+243",
    "Congo, Republic of the": "+242",
    "Costa Rica": "+506",
    "Cote d'Ivoire": "+225",
    "Croatia": "+385",
    "Cuba": "+53",
    "Cyprus": "+357",
    "Czech Republic": "+420",
    "Denmark": "+45",
    "Djibouti": "+253",
    "Dominica": "+1 767",
    "Dominican Republic": "+1 809, +1 829, +1 849",
    "Ecuador": "+593",
    "Egypt": "+20",
    "El Salvador": "+503",
    "Equatorial Guinea": "+240",
    "Eritrea": "+291",
    "Estonia": "+372",
    "Eswatini": "+268",
    "Ethiopia": "+251",
    "Fiji": "+679",
    "Finland": "+358",
    "France": "+33",
    "Gabon": "+241",
    "Gambia": "+220",
    "Georgia": "+995",
    "Germany": "+49",
    "Ghana": "+233",
    "Greece": "+30",
    "Grenada": "+1 473",
    "Guatemala": "+502",
    "Guinea": "+224",
    "Guinea-Bissau": "+245",
    "Guyana": "+592",
    "Haiti": "+509",
    "Honduras": "+504",
    "Hungary": "+36",
    "Iceland": "+354",
    "India": "+91",
    "Indonesia": "+62",
    "Iran": "+98",
    "Iraq": "+964",
    "Ireland": "+353",
    "Israel": "+972",
    "Italy": "+39",
    "Jamaica": "+1 876",
    "Japan": "+81",
    "Jordan": "+962",
    "Kazakhstan": "+7",
    "Kenya": "+254",
    "Kiribati": "+686",
    "Korea, North": "+850",
    "Korea, South": "+82",
    "Kosovo": "+383",
    "Kuwait": "+965",
    "Kyrgyzstan": "+996",
    "Laos": "+856",
    "Latvia": "+371",
    "Lebanon": "+961",
    "Lesotho": "+266",
    "Liberia": "+231",
    "Libya": "+218",
    "Liechtenstein": "+423",
    "Lithuania": "+370",
    "Luxembourg": "+352",
    "Madagascar": "+261",
    "Malawi": "+265",
    "Malaysia": "+60",
    "Maldives": "+960",
    "Mali": "+223",
    "Malta": "+356",
    "Marshall Islands": "+692",
    "Mauritania": "+222",
    "Mauritius": "+230",
    "Mexico": "+52",
    "Micronesia": "+691",
    "Moldova": "+373",
    "Monaco": "+377",
    "Mongolia": "+976",
    "Montenegro": "+382",
    "Morocco": "+212",
    "Mozambique": "+258",
    "Myanmar": "+95",
    "Namibia": "+264",
    "Nauru": "+674",
    "Nepal": "+977",
    "Netherlands": "+31",
    "New Zealand": "+64",
    "Nicaragua": "+505",
    "Niger": "+227",
    "Nigeria": "+234",
    "North Macedonia": "+389",
    "Norway": "+47",
    "Oman": "+968",
    "Pakistan": "+92",
    "Palau": "+680",
    "Palestine": "+970",
    "Panama": "+507",
    "Papua New Guinea": "+675",
    "Paraguay": "+595",
    "Peru": "+51",
    "Philippines": "+63",
    "Poland": "+48",
    "Portugal": "+351",
    "Qatar": "+974",
    "Romania": "+40",
    "Russia": "+7",
    "Rwanda": "+250",
    "Saint Kitts and Nevis": "+1 869",
    "Saint Lucia": "+1 758",
    "Saint Vincent and the Grenadines": "+1 784",
    "Samoa": "+685",
    "San Marino": "+378",
    "Sao Tome and Principe": "+239",
    "Saudi Arabia": "+966",
    "Senegal": "+221",
    "Serbia": "+381",
    "Seychelles": "+248",
    "Sierra Leone": "+232",
    "Singapore": "+65",
    "Slovakia": "+421",
    "Slovenia": "+386",
    "Solomon Islands": "+677",
    "Somalia": "+252",
    "South Africa": "+27",
    "South Sudan": "+211",
    "Spain": "+34",
    "Sri Lanka": "+94",
    "Sudan": "+249",
    "Suriname": "+597",
    "Sweden": "+46",
    "Switzerland": "+41",
    "Syria": "+963",
    "Taiwan": "+886",
    "Tajikistan": "+992",
    "Tanzania": "+255",
    "Thailand": "+66",
    "Timor-Leste": "+670",
    "Togo": "+228",
    "Tonga": "+676",
    "Trinidad and Tobago": "+1 868",
    "Tunisia": "+216",
    "Turkey": "+90",
    "Turkmenistan": "+993",
    "Tuvalu": "+688",
    "Uganda": "+256",
    "Ukraine": "+380",
    "United Arab Emirates": "+971",
    "United Kingdom": "+44",
    "United States": "+1",
    "Uruguay": "+598",
    "Uzbekistan": "+998",
    "Vanuatu": "+678",
    "Vatican City": "+39",
    "Venezuela": "+58",
    "Vietnam": "+84",
    "Yemen": "+967",
    "Zambia": "+260",
    "Zimbabwe": "+263"
};

  const detectSource = (url) => {
  if (url.includes("linkedin")) {
    return "LinkedIn";
  } else if (url.includes("juspay.in")) {
    return "Juspay Website";
  } else {
    return "Other Websites";
  }
};

   const handleSubmit = async (event) => {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    const data = {};
    const dob = selectedDate ? selectedDate.toISOString().split('T')[0] : '';
    data['Date of Birth'] = dob; 
    const applicationId = uuidv4();

    formData.forEach((value, key) => {
      data[key] = value;
      
    });
    data['ApplicationID'] = applicationId;
    //Add URL and port mentioned in FLask
    try {
      const response = await fetch('http://127.0.0.1:5000/submit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
      });

      if (response.ok) {
        setApplicants([...applicants, data]);
        form.reset();
        setSubmitted(true);
      } else {
        console.error('Failed to submit form');
        const errorMessage = await response.text();
        console.error('Error message:', errorMessage);
      }
    } catch (error) {
      console.error('Error submitting form:', error);
    }
  };

  return (
    <div className="App">
      {submitted ? ( // Show thank you message if form submitted
        <h1>Thank you for applying!</h1>
      ) : (
        <>
          <h1 style={{ color: 'black' }}>Begin your 10x with Juspay!</h1>
          <h2>Let's get started</h2>
        <form onSubmit={handleSubmit} className="applicant-form">
        
        <div className="input-group">
        <label htmlFor="resume">Upload your resume:</label>
        <input type="file" id="resume" name="Resume" accept=".pdf,.jpg,.jpeg,.png" required />
        </div>
        
        <div className="input-group">
        <label htmlFor="sourceUrl">Source URL:</label>
        <input type="text" id="sourceUrl" name="Source" placeholder="Enter the Source URL" required />
        </div>
        
        <div className="input-group">
        <label htmlFor="positionApplied">Position Applied for:</label>
        <input type="text" id="positionApplied" name="Position Applied for" required />
        </div>
        
        <div className="input-group">
        <label htmlFor="roleCategory">Role category:</label>
        <input type="text" id="roleCategory" name="Role category" required />
        </div>
        <div className="input-group">
        <label htmlFor="dob">Date of Birth:</label>
        <DatePicker
          id="dob"
          selected={selectedDate}
          onChange={(date) => setSelectedDate(date)}
          dateFormat="dd/MM/yyyy"
          showYearDropdown
          scrollableYearDropdown
          yearDropdownItemNumber={30}
          required
        />
        </div>

        <div className="input-group">
        <label htmlFor="name">Name:</label>
        <input type="text" id="name" name="Name" required />
        </div>
        
        <div className="input-group">
        <label>Gender:</label>
        <select name="Gender" required>
          {genderOptions.map((option, index) => (
            <option key={index} value={option}>{option}</option>
         ))}
        </select>
        </div>
        
        <div className="input-group">
          <label>Country:</label>
          <select name="Country" defaultValue="India" required>
          {Object.entries(countryCodes).map(([country, code], index) => (
          <option key={index} value={country}>
          {country} ({code})
          </option>
    ))}
         </select>
         </div>

        <div className="input-group">
        <label htmlFor="phoneNumber">Phone number:</label>
        <input type="text" id="phoneNumber" name="Phone number" required />
        </div>

        <div className="input-group">
        <label htmlFor="email">Email:</label>
        <input type="email" id="email" name="Email" required />
        </div>
        
        <div className="input-group">
                              <label htmlFor="college">College:</label>
    <select 
        id="college" 
        onChange={(e) => setSelectedCollege(e.target.value)}
        name="College"
    >
        <option value="others">Others</option>
        {colleges.map((college, index) => (
            <option key={index} value={college}>
                {college}
            </option>
        ))}
    </select>
</div>
{selectedCollege === "others" && (
    <div className="input-group">
        <label htmlFor="customCollege">Enter your college:</label>
        <input 
            type="text" 
            id="customCollege" 
            value={customCollege}
            onChange={(e) => setCustomCollege(e.target.value)}
            placeholder="Enter your college name..."
            name="Custom College"
        />
    </div>
)}
        <div className="input-group">
        <label htmlFor="gradYear">Under Graduation Year of Completion:</label>
        <input type="number" id="gradYear" name="Under Graduation Year of Completion" required />
        </div>
        
        <div className="input-group">
        <label htmlFor="currentCompany">Current Company:</label>
        <input type="text" id="currentCompany" name="Current Company" required />
        </div>
        
        <div className="input-group">
        <label>Experience (Years):</label>
        <select name="Experience in years" required>
         {yearsOfExperience.map((year, index) => (
        <option key={index} value={year}>{year}</option>
        ))}
        
        </select>
        </div>

        <div className="input-group">
        <label>Experience (Months):</label>
        <select name="Experience in months" required>
        {monthsOfExperience.map((month, index) => (
        <option key={index} value={month}>{month}</option>
        ))}
        </select>
        </div>

        
        <div className="input-group">
        <label htmlFor="expectedCTC">Expected CTC(Rs. Lakhs):</label>
        <input type="number" id="expectedCTC" name="Expected CTC (Rs.Lakhs)" required />
        </div>
        
        <div className="input-group">
        <label htmlFor="currentCTC">Current CTC (Rs.Lakhs):</label>
        <input type="number" id="currentCTC" name="Current CTC (Rs. Lakhs)" required />
        </div>
        <button type="submit">Submit</button>
        </form>
          </>
      )}

      {submitted ? null : ( // Show form if not submitted
        <div className="applicant-form">
          {/* ... (your form inputs) */}
        </div>
      )}
      <div className="applicant-list">
        {applicants.map((applicant, index) => (
          <div key={index} className="applicant-entry">
                    <h3>Applicant {index + 1}</h3>
                    <p><strong>Application ID:</strong> {applicant['ApplicationID']}</p>
                    <p><strong>Source:</strong> {applicant["Source"]}</p>
                    <p><strong>Position Applied for:</strong> {applicant["Position Applied for"]}</p>
                    <p><strong>Name:</strong> {applicant["Name"]}</p>
                    <p><strong>Gender:</strong> {applicant["Gender"]}</p>
                    <p><strong>Phone Number:</strong> {applicant["Phone number"]}</p>
                    <p><strong>Email:</strong> {applicant["Email"]}</p>
                    <p><strong>College:</strong> {applicant["College"]}</p>
                    <p><strong>Under Graduation Year:</strong> {applicant["Under Graduation Year of Completion"]}</p>
                    <p><strong>Current Company:</strong> {applicant["Current Company"]}</p>
                    <p><strong>Experience (Years):</strong> {applicant["Experience in years"]}</p>
                    <p><strong>Experience (Months):</strong> {applicant["Experience in months"]}</p>
                    <p><strong>Expected CTC (Rs.Lakhs):</strong> {applicant["Expected CTC (In Rs. Lakhs)"]}</p>
                    <p><strong>Current CTC (Rs.Lakhs):</strong> {applicant["Current CTC (In Rs. Lakhs)"]}</p>
            </div>
            ))}
      </div>
    </div>
  );
}

export default App;
