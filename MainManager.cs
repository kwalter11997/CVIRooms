using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Diagnostics;

using Debug = UnityEngine.Debug;
using static System.Net.Mime.MediaTypeNames;

public class MainManager : MonoBehaviour
{
    public static MainManager Instance;

    //Variables pertaining to the initial menu and participant info
    public GameObject menuObject;
    public TMP_InputField textField;
    public GameObject strtButton;

    //generic variables related to trial spawning and logging
    private float trialTime = 0;
    public bool IsInitialized;
    public GameObject CalibrationPoints;

    //associated eye coordinate variables
    private bool startEyetracker;

    //variables for the data file info
    private static string participantName;
    private string Date, runNumber;
    private int day, month, year;
    private string dayString, monthString;

    //file path strings
    private string rawEvents, fileCheck;

    private void Awake()
    {
        if (Instance != null) //if this isn't the first trial, don't create a new gameObject (maintains a single Manager)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    // Use this for initialization
    void Start()
    {
        saveGame(gameObject); //reference our mainManager (so can be accessed from other scripts)

        CalibrationPoints.SetActive(false);

        //gets and creates a date
        day = System.DateTime.Today.Day;
        month = System.DateTime.Today.Month;
        year = System.DateTime.Today.Year;

        //checks if day is less than 10
        if (day < 10)
        {
            dayString = "0" + day.ToString();
        }
        else
        {
            dayString = day.ToString();
        }

        //checks if month is less than 10
        if (month < 10)
        {
            monthString = "0" + month.ToString();
        }
        else
        {
            monthString = month.ToString();
        }

        Date = monthString + dayString + year.ToString();
    }

    void FixedUpdate()
    {
        // check for start button press
        Button strt = strtButton.GetComponent<Button>();
        strt.onClick.AddListener(startExperiment);
        strt.onClick.AddListener(saveName);

        //starts the experimental timers
        if (startEyetracker)
        {
            trialTime += Time.deltaTime;

            TextWriter rw = new StreamWriter(rawEvents, true);
            rw.WriteLine(trialTime + "," + EyeTrackingRay.objectname + "," +
                LeftEyePos.eyePos[0] + "," + LeftEyePos.eyePos[1] + "," + LeftEyePos.eyePos[2] + "," +
                RightEyePos.eyePos[0] + "," + RightEyePos.eyePos[1] + "," + RightEyePos.eyePos[2] + "," +
                LeftEyePos.eyeRot[0] + "," + LeftEyePos.eyeRot[1] + "," + LeftEyePos.eyeRot[2] + "," +
                RightEyePos.eyeRot[0] + "," + RightEyePos.eyeRot[1] + "," + RightEyePos.eyeRot[2]);
            rw.Close();
        }

        //close application situations
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            UnityEngine.Application.Quit();
        }
    }

    public void saveName()
    {
        participantName = textField.text;

        string name = System.Environment.UserName; //get the name of the current computer user        
        fileCheck = @"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\VR\Data\" + participantName + "_" + Date + "_Calibration" + ".csv";
        rawEvents = @"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\VR\Data\" + participantName + "_" + Date + "_CalibrationRAW" + ".csv";
        
        TextWriter tw = new StreamWriter(fileCheck, false); //write the new file
        tw.WriteLine("TrialTime, Point, Validated");
        tw.Close();

        TextWriter rw = new StreamWriter(rawEvents, false); //write the new file
        rw.WriteLine("TrialTime, ObjectName, Lx, Ly, Lz, Rx, Ry, Rz, LRotx, LRoty, LRotz, RRotx, RRoty, RRotz");
        rw.Close();
    }

    void startExperiment()
    {
        startEyetracker = true;

        menuObject.SetActive(false); //hide menu screen

        CalibrationPoints.SetActive(true);

        IsInitialized = true; //tell other functions/scripts to start experiment               
    }

    public void saveGame(GameObject g)
    {
        if (IsInitialized)
        {
            TextWriter tw = new StreamWriter(fileCheck, true);
            tw.WriteLine(trialTime + "," + EyeInteractable.point + "," + "Validated");
            tw.Close();
        }
    }
}
