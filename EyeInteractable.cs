using System;
using System.Collections;
using System.Diagnostics;
using UnityEngine;
using UnityEngine.Events;

public class EyeInteractable : MonoBehaviour
{
    MainManager save;

    public bool IsHovered { get; set; }

    public GameObject sphere;
    public static string point;

    [SerializeField]
    private UnityEvent<GameObject> OnObjectHover;

    [SerializeField]
    private Material OnHoverActiveMaterial;

    private MeshRenderer meshRenderer;
    private BoxCollider collider;

    // Start is called before the first frame update
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        collider = GetComponent<BoxCollider>();
    }

    // Update is called once per frame
    void Update()
    {
        if(IsHovered)
        {
            point = sphere.name;
            //meshRenderer.material.color = Color.Lerp(startColor, endColor, Mathf.PingPong(Time.time, 1));
            sphere.transform.localScale += new Vector3(-0.002f, -0.002f, -0.002f);
            OnObjectHover?.Invoke(gameObject);
            UnityEngine.Debug.Log(point);
                
            if (sphere.transform.localScale.x <= 0.2f) //once sphere hits this size, stop/turn green
            {
                save = GameObject.FindGameObjectWithTag("Manager").GetComponent<MainManager>(); //save validation time
                save.saveGame(gameObject);

                meshRenderer.material = OnHoverActiveMaterial;
                collider.enabled = false;   
            }
        }
    }
}
