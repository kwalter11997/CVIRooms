using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Diagnostics;

using Debug = UnityEngine.Debug;

public class MainManager : MonoBehaviour
{
    public static MainManager Instance;

    //Variables pertaining to the initial menu and participant info
    public GameObject menuObject;
    public TMP_InputField textField;
    public Toggle cond;
    public GameObject strtButton;

    // things to be logged
    public int Trial;
    public int[] CamPosA;
    public int[] CamPosB;
    public string[] RoomNameA;
    public string[] RoomNameB;
    public string[] ClutterA;
    public string[] ClutterB;

    //generic variables related to trial spawning and logging
    private float trialTime = 0;
    public bool IsInitialized;

    //variables for the data file info
    private static string participantName;
    private string Date, runNumber;
    private int day, month, year;
    private string dayString, monthString;

    //file path strings
    private string rawEvents, fileCheck;

    //game objects for the trial cover
    public GameObject coverObject;

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
        trialTime += Time.deltaTime;

        //TextWriter rw = new StreamWriter(rawEvents, true);
        //rw.WriteLine(ViewEyeData.x + "," + ViewEyeData.y + "," + trialTime + "," + lostParticipant + "," + screenbounds);
        //rw.Close();
    }

    public void saveName()
    {
        participantName = textField.text;

        string name = System.Environment.UserName; //get the name of the current computer user
        fileCheck = @"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\VR\Data\" + participantName + "_" + Date + ".csv"; //check if file exists
        //fileCheck = @"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\VR\Data\" + "XX" + "_" + Date + ".csv"; //fileame
        //rawEvents = @"C:\Users\" + name + @"\Dropbox\Kerri_Walter\CVIRooms\VR\Data\" + participantName + "_" + Date + "_RAW" + ".csv";

        TextWriter tw = new StreamWriter(fileCheck, false); //write the new file
        tw.WriteLine("Trial, Condition, RoomName, Clutter, StartEnd, TrialTime");
        tw.Close();

        //TextWriter rw = new StreamWriter(rawEvents, false); //write the new file
        //rw.WriteLine("ViewEyeDataX, ViewEyeDataY, TrialTime, LostParticipant, Screenbounds");
        //rw.Close();
    }

    void startExperiment()
    {
        //startEyetracker = true;

        menuObject.SetActive(false); //hide menu screen

        IsInitialized = true; //tell trial counter to start experiment               
        TrialCounter.counter = 0;
        Trial = 0;

    }

    public void saveGame(GameObject g)
    {
        if (IsInitialized)
        {
            TextWriter tw = new StreamWriter(fileCheck, true);
            if (TrialCounter.startTrial) //start of trial
            {
                if (Trial == 0)
                {
                    tw.WriteLine(Trial + "," + "Practice" + "," + "Practice" + "," + "Practice" + "," + "StartTrial" + "," + trialTime);
                }

                else if (cond.isOn)
                {
                    tw.WriteLine(Trial + "," + XRCamMove.roomType + "," + RoomNameA[Trial - 1] + "," + ClutterA[Trial - 1] + "," + "StartTrial" + "," + trialTime);
                }
                else
                {
                    tw.WriteLine(Trial + "," + XRCamMove.roomType + "," + RoomNameB[Trial - 1] + "," + ClutterB[Trial - 1] + "," + "StartTrial" + "," + trialTime);
                }
            }
            else //end of trial
            {
                if (Trial == 0)
                {
                    tw.WriteLine(Trial + "," + "Practice" + "," + "Practice" + "," + "Practice" + "," + "EndTrial" + "," + trialTime);
                }

                else if (cond.isOn)
                {
                    tw.WriteLine(Trial + "," + XRCamMove.roomType + "," + RoomNameA[Trial - 1] + "," + ClutterA[Trial - 1] + "," + "EndTrial" + "," + trialTime);
                }
                else
                {
                    tw.WriteLine(Trial + "," + XRCamMove.roomType + "," + RoomNameB[Trial - 1] + "," + ClutterB[Trial - 1] + "," + "EndTrial" + "," + trialTime);
                }
            }
            tw.Close();
        }
    }
}
