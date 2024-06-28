package com.adam.seasalon.ui

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.adam.seasalon.MainActivity
import com.adam.seasalon.R
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase

class RegisterActivity : AppCompatActivity() {

    private lateinit var auth: FirebaseAuth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)

        auth = FirebaseAuth.getInstance()

        val etUserId = findViewById<EditText>(R.id.ed_userId)
        val etUsername = findViewById<EditText>(R.id.ed_full_name)
        val etEmail = findViewById<EditText>(R.id.ed_email)
        val etPhoneNumber = findViewById<EditText>(R.id.ed_phone_number)
        val etPassword = findViewById<EditText>(R.id.password)
        val btnRegister = findViewById<Button>(R.id.signupButton)
        val loginTextView = findViewById<TextView>(R.id.loginTextView) // Deklarasi TextView untuk kembali ke LoginActivity
        val db = Firebase.firestore

        loginTextView.setOnClickListener {
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }

        btnRegister.setOnClickListener {
            val userId = etUserId.text.toString()
            val username = etUsername.text.toString()
            val email = etEmail.text.toString()
            val phoneNumber = etPhoneNumber.text.toString()
            val password = etPassword.text.toString()

            if (userId.isNotEmpty() && username.isNotEmpty() && email.isNotEmpty() && phoneNumber.isNotEmpty() && password.isNotEmpty()) {
                auth.createUserWithEmailAndPassword(email, password)
                    .addOnCompleteListener(this) { task ->
                        if (task.isSuccessful) {
                            val user = auth.currentUser
                            val userInfo = hashMapOf(
                                "userId" to userId,
                                "username" to username,
                                "email" to email,
                                "phoneNumber" to phoneNumber
                            )

                            user?.let {
                                db.collection("users").document(it.uid)
                                    .set(userInfo)
                                    .addOnSuccessListener {
                                        startActivity(Intent(this, MainActivity::class.java))
                                        finish()
                                    }
                                    .addOnFailureListener { e ->
                                        Toast.makeText(this, "Failed to save user info: ${e.message}", Toast.LENGTH_SHORT).show()
                                    }
                            }
                        } else {
                            Toast.makeText(this, "Registration Failed: ${task.exception?.message}", Toast.LENGTH_SHORT).show()
                        }
                    }
            } else {
                Toast.makeText(this, "Please fill out all fields.", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
