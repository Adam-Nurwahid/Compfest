package com.adam.seasalon.ui

import android.app.ProgressDialog
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.adam.seasalon.MainActivity
import com.adam.seasalon.R
import com.google.firebase.auth.FirebaseAuth

class LoginActivity : AppCompatActivity() {

    private lateinit var auth: FirebaseAuth
    private lateinit var etEmail: EditText
    private lateinit var etPassword: EditText
    private lateinit var btnLogin: Button
    private lateinit var progressDialog: ProgressDialog

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        auth = FirebaseAuth.getInstance()

        etEmail = findViewById(R.id.UserId)
        etPassword = findViewById(R.id.password_login)
        btnLogin = findViewById(R.id.loginButton)
        val tvRegister = findViewById<TextView>(R.id.registerText)

        progressDialog = ProgressDialog(this)
        progressDialog.setMessage("Logging in...")
        progressDialog.setCancelable(false)

        // Disable button initially
        btnLogin.isEnabled = false

        // Add TextChangedListener to enable/disable button
        etEmail.addTextChangedListener(loginTextWatcher)
        etPassword.addTextChangedListener(loginTextWatcher)

        btnLogin.setOnClickListener {
            val email = etEmail.text.toString()
            val password = etPassword.text.toString()

            if (email.isNotEmpty() && password.isNotEmpty()) {
                progressDialog.show() // Show progress dialog

                auth.signInWithEmailAndPassword(email, password)
                    .addOnCompleteListener(this) { task ->
                        progressDialog.dismiss() // Dismiss progress dialog
                        if (task.isSuccessful) {
                            startActivity(Intent(this, MainActivity::class.java))
                            finish()
                        } else {
                            Toast.makeText(this, "Authentication Failed.", Toast.LENGTH_SHORT).show()
                        }
                    }
            } else {
                Toast.makeText(this, "Please fill out all fields.", Toast.LENGTH_SHORT).show()
            }
        }

        tvRegister.setOnClickListener {
            startActivity(Intent(this, RegisterActivity::class.java))
        }
    }

    // TextWatcher to enable/disable button based on input fields
    private val loginTextWatcher = object : TextWatcher {
        override fun afterTextChanged(s: Editable?) {
            val emailInput = etEmail.text.toString().trim()
            val passwordInput = etPassword.text.toString().trim()

            btnLogin.isEnabled = emailInput.isNotEmpty() && passwordInput.isNotEmpty()
        }

        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            // Not needed
        }

        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            // Not needed
        }
    }
}
