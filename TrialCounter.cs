using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

public class TrialCounter: MonoBehaviour
{
    MainManager save;

    public static TrialCounter Instance;

    public static int counter = 0;
    public static bool startTrial;
    public bool target;
    public bool fixCross;
    public Canvas breakScreen;
    public static bool end = false;
    public Toggle cond;

    void Awake()
    {
        Instance = this;

        //MainManager.Instance.Trial = counter;
        //coverObject.enabled = true; // show fix cross
        target = false;

        breakScreen.enabled = false;
    }

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(TrialManager());
    }

    IEnumerator TrialManager()
    {
        while (true)
        {
            yield return new WaitUntil(() => MainManager.Instance.IsInitialized);

            fixCross = true;
            yield return new WaitForSeconds(1); //wait for fixcross
            fixCross = false;

            target = true;

            yield return new WaitForSeconds(1); //wait for target

            target = false;

            startTrial = true;
            save = GameObject.FindGameObjectWithTag("Manager").GetComponent<MainManager>(); //save stuff at start of trial
            save.saveGame(gameObject);

            yield return new WaitForSeconds(1); //show room

            startTrial = false;
            save = GameObject.FindGameObjectWithTag("Manager").GetComponent<MainManager>(); //save stuff at end of trial
            save.saveGame(gameObject);

            //end experiment if all trials completed
            if (counter == 22 & end == true)
            {
                Debug.Log("Application Quit");
                Application.Quit();
            }

            //break at halfway point
            if (counter == 22)
            {
                breakScreen.enabled = true;
                counter = 0; //reset to 0
                end = true;

                if (cond.isOn) //switch toggle
                {
                    cond.isOn = false;
                }
                else
                {
                    cond.isOn = true;
                }

                while (!Input.GetKeyDown(KeyCode.Return)) //press enter to continue
                {
                    yield return null;
                }
                breakScreen.enabled = false;
            }

            //timing stuff           
            counter++; //count trial
            MainManager.Instance.Trial = counter;
        }
    }
}
