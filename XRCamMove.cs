using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class XRCamMove : MonoBehaviour
{
    public GameObject XRRig;
    public int xpos;
    public Toggle cond;
    public static string roomType;

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(Move());
    }

    IEnumerator Move() 
    {
        while (true)
        {
            yield return new WaitUntil(() => MainManager.Instance.IsInitialized);

            yield return new WaitUntil(() => TrialCounter.Instance.fixCross == true);
            XRRig.transform.position = new Vector3(170, 0.818f, -30.083f); //move XRRig to fixCross

            if (MainManager.Instance.Trial == 0) //first room is practice
            {
                yield return new WaitUntil(() => TrialCounter.Instance.target == true);
                XRRig.transform.position = new Vector3(155, 0.818f, -30.083f); //move XRRig to practice target

                yield return new WaitUntil(() => TrialCounter.Instance.target == false);
                XRRig.transform.position = new Vector3(155, 0.818f, -2.083f); //move XRRig to practice room
            }

            else if (cond.isOn) //congruent rooms
            {
                roomType = "Congruent";

                yield return new WaitUntil(() => TrialCounter.Instance.target == true);
                xpos = MainManager.Instance.CamPosA[MainManager.Instance.Trial - 1];
                XRRig.transform.position = new Vector3(xpos, 0.818f, -30.083f); //move XRRig to target

                yield return new WaitUntil(() => TrialCounter.Instance.target == false);
                XRRig.transform.position = new Vector3(xpos, 0.818f, -2.083f); //move XRRig to room

            }
            else //incongruent rooms
            {
                roomType = "Incongruent";

                yield return new WaitUntil(() => TrialCounter.Instance.target == true);
                xpos = MainManager.Instance.CamPosB[MainManager.Instance.Trial - 1];
                XRRig.transform.position = new Vector3(xpos, 0.818f, -120.083f); //move XRRig to target

                yield return new WaitUntil(() => TrialCounter.Instance.target == false);
                XRRig.transform.position = new Vector3(xpos, 0.818f, -92.083f); //move XRRig to room
            }
        }
    }
}
